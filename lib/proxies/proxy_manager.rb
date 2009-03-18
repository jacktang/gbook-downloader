module GBookDownloader
  module Proxies
    class ProxyManager

      attr_reader :proxy_instance_candidate_pool
      
      def initialize()
        @proxy_instance_candidate_pool = []
      end

      #
      # Return: ProxyInstance
      def select
        @proxy_instance_candidate_pool.pop
      end

    end
  end
end
