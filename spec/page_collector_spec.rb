require File.dirname(__FILE__) + '/spec_helper'

describe GBookDownloader::PageCollector do 
  before do 
    @book = GBookDownloader::Book.new
    @book.about_url = 'http://books.google.com/books?id=Tmy8LAaVka8C'
    @book.preview_url = 'http://books.google.com/books?id=Tmy8LAaVka8C&printsec=frontcover'
    @book.total_page_count = 32

    @page_collector = GBookDownloader::PageCollector.new(@book, '~/books')
  end

  it 'should return not empty cookie' do 
    cookie_str = @page_collector.get_cookie(@book.preview_url, nil)
    cookie_str.should_not == ''
  end

  it 'should return "http://books.google.com/books?id=Tmy8LAaVka8C&lpg=PP1" as prefix' do 
    load_script = @page_collector.main_script(@book)
    @page_collector.prefix_in_preview(load_script).should == 'http://books.google.com/books?id=Tmy8LAaVka8C&lpg=PP1'
  end
end
