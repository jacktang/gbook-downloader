module GBookDownloader
  module Proxies
    class ProxyInstance
      attr_reader :host
      attr_accessor :port
      attr_accessor :country

      def initialize(host, port=3128, country=nil)
        @host = host
        @port = port 
        @country = country
      end
    end
  end
end
