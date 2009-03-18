require 'rubygems'
require 'prawn'

module GBookDownloader
  class PdfBookWeaver
    attr_reader :output_file

    def initialize(pages, output_file)
      @pages = pages
      @output_file = output_file
    end
    
    def weave
      Prawn::Document.generate(@output_file, :page_layout => :landscape) do     
        pigs = "#{Prawn::BASEDIR}/data/images/pigs.jpg" 
        image pigs, :at => [50,450], :scale => 1.0 
      end
    end
  end
end

if __FILE__ == $0
  output = File.dirname(__FILE__) + '/test.pdf'
  weaver = GBookDownloader::PdfBookWeaver.new(output)
  weaver.weave
end

=begin
      # PDF::Writer#image returns the image object that was added.
      i0 = pdf.image "../images/chunkybacon.jpg", :resize => 0.75
      pdf.image "../images/chunkybacon.png", :justification => :center, :resize => 0.75
=end
