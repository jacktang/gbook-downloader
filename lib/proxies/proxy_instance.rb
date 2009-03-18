module GBookDownloader
  module Proxies
    class ProxyInstance
      attr_reader :host
      attr_reader :port
      
      def initialize(host, port=3128)
        @host = host
        @port = port 
      end
    end
  end
end
