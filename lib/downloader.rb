module GBookDownloader
  class Downloader
    
    attr_reader :book
    attr_reader :output_dir

    def initialize(book_url, output_dir)
      book_id = get_book_id(book_url)
      @output_dir = output_dir

      @proxy_manager = GBookDownloader::ProxyManager.new
      @page_collector = GBookDownloader::PageCollector.new
    end

    def download
      @book = get_book_attributes(book_id)

      downloaded_page_count = 0
      
      while((downloaded_page_count < @book.total_page_count) && (@proxy_manager.instance_available?)) do
        proxy_instance = @proxy_manager.select
        if(@proxy_manager.test(proxy_instance))
          @page_collector.for(@book).select_proxy(proxy_instance).collect
        end
      end

      book_weaver = GBookDownloader::HtmlBookWeaver.new(@output_dir)
      book_weaver.weave
    end


    def get_book_id(str)
      regexp = Regexp.new("id=([a-zA-Z0-9\\-_]+)")
      match = regexp.match(str)
      return match[1]
    end

    def get_book_attributes(book_id)
      book = GBookDownloader::Book.new
      book.book_id = book_id
      book.preview_url = ""
      book.about_url = ""
      book.title = ""
      book.total_page_count = 0
      return book
    end

  end
end
