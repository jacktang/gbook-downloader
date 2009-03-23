require 'rubygems'
require 'sqlite3'
require 'fileutils'
require 'proxy_http_client'
require 'simple_logger'

module GBookDownloader
  module Proxies
    class ProxyManager

      include GBookDownloader::SimpleLogger

      attr_reader :proxy_candidate_pool
      attr_accessor :proxy_providers

      GOOGLE_BOOK_HOME = 'http://books.google.com'

      def initialize(hidden_local=false)
        @proxy_providers = []
        @proxy_candidate_pool = []
        @proxy_candidate_pool.unshift(local_proxy_instance) if(not hidden_local)
        init_proxy_db
      end

      def init_proxy_db
        local_db_file = '/tmp/gbook-downloader/proxy_db'
        if(!File.exist?(local_db_file))
          FileUtils.mkdir_p(File.dirname(local_db_file))
          FileUtils.touch(local_db_file)
          # TODO: add exception handling
          begin
            @proxy_db = SQLite3::Database.new(local_db_file)
            @proxy_db.execute('drop table proxies')
            @proxy_db.execute('create table proxies(host varchar(255), port smallint, country varchar(40), failed_count smallint)')
            logger.info('init proxy database successfully')
          rescue Exception => e
            logger.error("ERROR! #{e.message}")
            exit!
          end
        else
          @proxy_db = SQLite3::Database.new(local_db_file)
        end
      end

      def load_proxy_instances
        # query_sql = 'select host, port, country from proxies where failed_count < 6'
        query_sql = 'select host, port, country from proxies'
        @proxy_db.execute( query_sql ) do |row|
          host, port, country = row
          instance = GBookDownloader::Proxies::ProxyInstance.new(host, port, country)
          @proxy_candidate_pool << instance
        end
      end

      def collect_proxies
        (@proxy_providers || []).each do |provider|
          provider.proxy_instances.each do |instance|
            if(test(GOOGLE_BOOK_HOME, instance))
              logger.debug("-> proxy #{instance.host}:#{instance.port}")
              @proxy_candidate_pool << instance
              save_proxy_instance(instance)
            end
          end
        end
      end

      #
      # Return: ProxyInstance
      def select
        return @proxy_candidate_pool.shift
      end

      def instance_available?
        return !@proxy_candidate_pool.empty?
      end

      def local_proxy?(proxy_instance)
        return(proxy_instance == :__local__)
      end

      def local_proxy_instance
        return :__local__
      end

      def test(test_url, proxy_instance)
        if(proxy_instance)
          return true if local_proxy?(proxy_instance) # always skip local

          http_client = GBookDownloader::ProxyHttpClient.new
          response_io = http_client.get(test_url, nil, proxy_instance) rescue nil
          if(response_io)
            status = response_io.status[0] rescue nil
            return true if(status && status.to_i == 200)
          end
          return false
        end
        return false
      end

      def save_proxy_instance(proxy)
      
        query_sql = ["select host from proxies where host=? and port=?", proxy.host, proxy.port]

        host = @proxy_db.get_first_value( *query_sql )
        if(host.nil?)
          insert_sql = ["insert into proxies(host, port, country) values (?, ?, ?)",
                        proxy.host, proxy.port, proxy.country]
          @proxy_db.execute( *insert_sql )
        end
      end
      
      def incr_failed_count(proxy)
        # make sure thread safe
        query_sql = ["select failed_count from proxies where host=? and port=?", host, port]
        failed_count = db.get_first_value(*query_sql).to_i rescue 0
        update_sql = "update proxies set failed_count = ? where host = ? and port = ?"
        @proxy_db.execute( *update_sql )
      end

    end
  end
end
