module GBookDownloader
  class Version
    MAIN  = 1
    MAJOR = 0
    MINOR = 0

    class << self
      def value
        return "#{MAIN}.#{MAJOR}.#{MINOR}"
      end
    end
  end
end
