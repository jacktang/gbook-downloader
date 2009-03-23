require 'rubygems'
require 'nokogiri'
require 'book'
require 'proxies'
require 'proxy_http_client'
require 'page_collector'
require 'book_weaver'
require 'simple_logger'

module GBookDownloader
  class Downloader

    include GBookDownloader::SimpleLogger
    
    attr_reader :book
    attr_reader :output_dir

    def initialize(book_url, output_dir)
      @book = GBookDownloader::Book.new
      @book.book_id = get_book_id(book_url) 
      @output_dir = output_dir
      @proxy_manager = GBookDownloader::Proxies::ProxyManager.new(true)
      @proxy_manager.proxy_providers << GBookDownloader::Proxies::RosinstrumentProvider.new
    end

    def download

      # @proxy_manager.collect_proxies
      @proxy_manager.load_proxy_instances

      logger.info "start downloading book #{@book.book_id}"

      fillup_book_attributes!
      @page_collector = GBookDownloader::PageCollector.new(@book, @output_dir)
      proxy_test = GBookDownloader::Proxies::ProxyManager::GOOGLE_BOOK_HOME
      
      while((@page_collector.downloaded_page_count < @book.total_page_count) && 
               (@proxy_manager.instance_available?)) do
        proxy_instance = @proxy_manager.select

        if(@proxy_manager.test(proxy_test, proxy_instance))
          if(@proxy_manager.local_proxy?(proxy_instance))
            logger.info("adopt no proxy")
            proxy_instance = nil 
          else
            logger.info("adopt proxy #{proxy_instance.host}:#{proxy_instance.port}")
          end
          @page_collector.adopt_proxy(proxy_instance).collect
        end
      end

      logger.info("weave the book under dir #{@output_dir}")
      book_weaver = GBookDownloader::BookWeaver::HtmlBookWeaver.new
      book_weaver.weave(@book, @output_dir)
    end


    def get_book_id(str)
      regexp = Regexp.new("id=([a-zA-Z0-9\\-_]+)")
      match = regexp.match(str)
      return match[1]
    end

    def fillup_book_attributes!
      book_id = @book.book_id
      @book.about_url = "http://books.google.com/books?id=#{book_id}"
      @book.preview_url = "#{book.about_url}&printsec=frontcover"
      
      http_client = GBookDownloader::ProxyHttpClient.new
      begin
        require 'open-uri'
        open("#{book.about_url}&rview=#{rand(8743)}")
        doc = Nokogiri::HTML(http_client.get(http_client))
      rescue Exception => e
        puts e.message
      end
      title = doc.css('h2.title').first.text
      total_pages = doc.css('div.bookinfo_section_line').last.text
      
      @book.title = title
      if total_pages
        @book.total_page_count = total_pages.split(' ').first.to_i
      end
    end
  end
end
