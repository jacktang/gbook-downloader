require File.dirname(__FILE__) + '/spec_helper'

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
