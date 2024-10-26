require File.dirname(__c:\Users\Chris Millerin\Desktop\RenamerDiff\gbook-downloader\spec\spec_helper.rbFILE__) + '/spec_helper'

describe GBookDownloader::Downloader do 
  before do
    about_book_url = 'http://books.google.com/books?id=Tmy8LAaVka8C'
    @output_dir = '~/books'
    @downloader = GBookDownloader::Downloader.new(about_book_url, @output_dir)
  end

  it 'should return "Tmy8LAaVka8C" as book id' do 
    @downloader.book.should be_instance_of(GBookDownloader::Book)
    @downloader.book.book_id.should == 'Tmy8LAaVka8C'
  end

  it 'should return all correct attribute after running "fillup_book_attributes!"' do 
    @downloader.fillup_book_attributes!
    book = @downloader.book
    book.should be_instance_of(GBookDownloader::Book)
    book.title.should == "Sometimes It's Turkey, Sometimes It's Feathers"
    book.title.should_not == "Sometimes It's Turkey, Sometimes It's Feathers "
    book.total_page_count.should == 32
    book.about_url.should == 'http://books.google.com/books?id=Tmy8LAaVka8C'
    book.preview_url.should == 'http://books.google.com/books?id=Tmy8LAaVka8C&printsec=frontcover'
  end

  it 'should warn that there is no total page count information available' do
    #book_url = ''
    #downloahttps://www.google.co.uk/books/edition/Airbus_A320_Limitations_and_Performance/lyhjEAAAQBAJ?hl=en&gbpv=1&dq=airbus&printsec=frontcoverder = GBookDownloader::Downloader.new(book_url, @output_dir)
  end
end
