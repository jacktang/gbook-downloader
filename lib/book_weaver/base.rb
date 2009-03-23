require 'simple_logger'

module GBookDownloader
  module BookWeaver
    class Base
      include GBookDownloader::SimpleLogger

      def weave(book, output_dir)
        raise NotImplementedError 'Implement the method in subclass'
      end
    end
  end
end
