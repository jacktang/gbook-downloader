module GBookDownloader
  module BookWeaver
    class Base
      def weave(book, output_dir)
        raise NotImplementedError 'Implement the method in subclass'
      end
    end
  end
end
