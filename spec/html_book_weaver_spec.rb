require File.dirname(__FILE__) + '/spec_helper'https://www.google.co.uk/books/edition/Airbus_A320_Limitations_and_Performance/lyhjEAAAQBAJ?hl=en&gbpv=1&dq=airbus&printsec=frontcover
module GBookDownloader
  class Book
    attr_accessor :preview_url
    attr_accessor :about_url
    attr_accessor :title
    attr_accessor :book_id
    attr_reader :total_page_count
    
    attr_reader :pages # [pid] = [remote_src, local_src]
    attr_reader :page_order
    
    def initialize
      @pages = {}
      @page_order = []
    end

    def total_page_count=(total)
      @total_page_count = total
      @page_order = [nil] * total if(total > 0)
    end

    def title_acts_as_dir
      return sanitize_filename(@title)
    end

    def to_s
      summary = <<EOF
book_id: #{@book_id}
  title: #{@title}
  about: #{@about_url}
preview: #{@preview_url}
  pages: #{@total_page_count}
EOF
      page_detail = ""
      page_no = 1
      page_order.each do |pid|
        if(!pid.nil?)
          src = pages[pid].first rescue nil
          page_detail = page_detail + "\n#{page_no}# #{pid}: #{src.inspect}"
          page_no = page_no + 1
        end
      end

      return summary + page_detail
    end

    private
    def sanitize_filename(filename)
      return unless filename
      returning filename.strip do |name|
        # NOTE: File.basename doesn't work right with Windows paths on Unix
        # get only the filename, not the whole path
        name.gsub! /^.*(\\|\/)/, ''
        
        # Finally, replace all non alphanumeric, underscore or periods with underscore
        name.gsub! /[^A-Za-z0-9\.\-]/, '_'
      end
    end

    def returning(value)
      yield(value)
      value
    end

  end
end
describe GBookDownloader::BookWeaver::HtmlBookWeaver do 
  before do 
    base = File.dirname(__FILE__)
    @book = GBookDownloader::Book.new
    @book.title = "Sometimes It's Turkey, Sometimes It's Feathers"
    @book.about_url = 'http://books.google.com/books?id=Tmy8LAaVka8C'
    @book.preview_url = 'http://books.google.com/books?id=Tmy8LAaVka8C&printsec=frontcover'
    @book.total_page_count = 32
    @book.pages['PP1']  = ['', "#{base}/data/books/Tmy8LAaVka8C/PP1.jpg"]
    @book.pages['PT10'] = ['', "#{base}/data/books/Tmy8LAaVka8C/PT10.jpg"]
    @book.pages['PT11'] = ['', "#{base}/data/books/Tmy8LAaVka8C/PT11.jpg"]
    @book.page_order[0] = 'PP1'
    @book.page_order[1] = 'PT10'
    @book.page_order[2] = 'PT11'

    @html_weaver = GBookDownloader::BookWeaver::HtmlBookWeaver.new
    
  end

  it 'should produce "index.html"' do
    output_dir = File.dirname(__FILE__) + '/_output'
    @html_weaver.weave(@book, output_dir)
  end
end
