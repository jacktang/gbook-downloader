require 'erb'
require 'fileutils'

module GBookDownloader
  module BookWeaver
    class HtmlBookWeaver < Base
      def initialize
        @template_file = File.expand_path(File.dirname(__FILE__) + '/../../templates/dark/book.rhtml')
      end

      # 
      # output_dir
      #   |
      #   |-book_title
      #   |  |-- pages
      #   |  |    |-- PT1.jpg
      #   |  |    |-- PP10.jpg
      #   |  |     ...
      #   |  |
      #   |  |-index.html
      #   
      def weave(book, output_dir)
        book_dir_name = book.title_acts_as_dir
        book_dir = File.expand_path(File.join(output_dir, book_dir_name))
        pages_dir = File.join(book_dir,'pages')
        FileUtils.mkdir_p(pages_dir)

        @local_pages = []
        pages = book.pages
        
        book.page_order.each do |pid|
          if(pages[pid] && pages[pid][1])
            src = pages[pid][1]
            dest = "pages/#{File.basename(src)}"
            @local_pages << [pid, src, dest]
          end
        end

        # copy images to dest dir
        @local_pages.each do |tuple|
          FileUtils.cp(tuple[1], pages_dir)
        end

        # generate the book entry
        template = ''
        File.open(@template_file).each do |line|
          template = template + line
        end

        index_html = File.join(book_dir, 'index.html')
        File.open(index_html, 'w') do |file|
          file.puts ERB.new(template).result(binding)
        end

      end
    end
  end
end
