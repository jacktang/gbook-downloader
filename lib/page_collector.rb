require 'rubygems'
require 'nokogiri'
require 'json'
require 'proxy_http_client'
require 'simple_logger'

module GBookDownloader
  #
  # Collect page in every book preview
  #
  class PageCollector

    include GBookDownloader::SimpleLogger

    attr_reader :proxy_instance
    attr_reader :book
    attr_reader :dest_dir
    attr_reader :downloaded_page_count
    
    def initialize(book, dest_dir)
      @book = book
      @dest_dir = dest_dir
      @tmp_dir = '/tmp'
      @downloaded_page_count = 0
      @http_client = GBookDownloader::ProxyHttpClient.new
    end

    def adopt_proxy(proxy_instance)
      @proxy_instance = proxy_instance
      return self
    end

    def main_script(book)
      preview_doc = Nokogiri::HTML(@http_client.get(book.preview_url, @preview_cookie, @proxy_instance))
      return preview_doc.xpath('//script').last.content 
    end

    def collect

      # TODO: the retry should be think twice
      begin
        preview_url = @book.preview_url
        @preview_cookie = get_cookie(preview_url, @proxy_instance)
        logger.debug('cookie is #{@preview_cookie.inspect}')

        load_script = main_script(@book)
        pid_prefix = prefix_in_preview(load_script)
      rescue Exception => e
        retry
      end

      process_pids = [] 
      # we only process the page whose src is null
      pids_in_preview(load_script).each do |pid|
        if(@book.pages[pid].nil? || @book.pages[pid][0].nil?) # 'src' is nil
          process_pids << pid
        end
      end

      process_pids.each do |pid|
        purl = page_url(pid_prefix, pid)
        logger.debug "process page #{purl}"

        download_queue = {}
        json_response = @http_client.get(purl, @preview_cookie, @proxy_instance) do |f|
          json_response = f.read
          json_object = JSON.parse(json_response)
          pages = json_object["page"]
          pages.each do |page|
            pid = page["pid"]
            src = page["src"]
            order = page["order"]
            if(pid && !@book.pages.has_key?(pid))
              @book.pages[pid] = []
            end
            if(src && @book.pages[pid][0].nil?)
              src = src.gsub(/x26/,'&')
              @book.pages[pid][0] = src
              download_queue[pid] = src if @book.pages[pid][1].nil?
            end
            if(order)
              index = order.to_i
              @book.page_order[index] = pid
            end
          end
        end
        download_pages(download_queue, @dest_dir)
        sleep 2
      end
    end


    def download_pages(download_queue, dest_dir)
      return unless download_queue
      
      logger.info('start downloading book pages ...') if not download_queue.empty?
      
      tmp_book_dir = File.join(@tmp_dir, book.book_id)
      FileUtils.mkdir_p(tmp_book_dir)      
      
      download_queue.each do |pid, src|
        @http_client.get(src, @preview_cookie, @proxy_instance) do |page|
          # TODO: content-type auto recogization
          open("#{tmp_book_dir}/#{pid}.jpg", "wb") do |local_file|
            local_file.write(page.read)
            logger.debug("download page #{src.inspect} and save as #{local_file.path}")
            @book.pages[pid][1] = File.expand_path(local_file.path)
            @downloaded_page_count = @downloaded_page_count + 1
          end
        end
      end
    end

    def get_cookie(entry_url, proxy_instance)
      cookie = Hash.new
      @http_client.get(entry_url, nil, proxy_instance){|f| f.meta }['set-cookie'].scan(/([a-zA-Z_-]+)=([^;\s]+);/){
        cookie[$1]=$2
      }
      return cookie.map{|x|x.join('=')}.join('; ')
    end

    def page_url(prefix, pid, sig='')
      return "#{prefix}&pg=#{pid}&sig=#{sig}&jscmd=click3"
    end

    def prefix_in_preview(str)
      regexp = Regexp.compile('"prefix":"([^"]+)"')
      # puts "#{str.inspect}"
      "document.getElementById('content_ads_content').style.display ='';"
      matche = regexp.match(str)
      # FIXME: the match might be nil
      return matche[1].gsub(/\\x26/,'&')
    end


    def pids_in_preview(str)
      regexp = Regexp.compile('"pid":"([^"]+)","src"')
      match = regexp.match(str)
      first_pid = match[1]

      pids = []
      pids << first_pid

      regex = Regexp.compile('\{"pid":"([^"]+)"\}')
      purl = page_url(prefix_in_preview(str), first_pid)      
      response_body = @http_client.get(purl, @preview_cookie, @proxy_instance) do |response|
        response_body = response.read
        matches = response_body.scan(regex)
        matches.each do |match|
          pids << match.first
        end
      end

      pids.uniq!
      return pids
    end

  end
end
