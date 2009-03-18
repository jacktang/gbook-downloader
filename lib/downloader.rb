require 'rubygems'
require 'nokogiri'
require 'book'
require 'proxies'
require 'proxy_http_client'
require 'page_collector'
require 'book_weaver'

module GBookDownloader
  class Downloader
    
    attr_reader :book
    attr_reader :output_dir

    def initialize(book_url, output_dir)
      @book = GBookDownloader::Book.new
      @book.book_id = get_book_id(book_url) 
      @output_dir = output_dir
      @proxy_manager = GBookDownloader::Proxies::ProxyManager.new
    end

    def download

      fillup_book_attributes!
      @page_collector = GBookDownloader::PageCollector.new(@book)

      while((@page_collector.downloaded_page_count < @book.total_page_count) && 
               (@proxy_manager.instance_available?)) do
        proxy_instance = @proxy_manager.select
        if(@proxy_manager.test(proxy_instance))
          @page_collector.select_proxy(proxy_instance).collect
        end
      end

      book_weaver = GBookDownloader::HtmlBookWeaver.new
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
      doc = Nokogiri::HTML(http_client.get(book.about_url))
    
      title = doc.css('h2.title').first.text
      total_pages = doc.css('div.bookinfo_section_line').last.text
      
      @book.title = title
      if total_pages
        @book.total_page_count = total_pages.split(' ').first.to_i
      end
    end
  end
end
