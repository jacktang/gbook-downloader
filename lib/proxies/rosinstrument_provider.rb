require 'rubygems'
require 'open-uri'
require 'nokogiri'
require 'proxy_http_client'

module GBookDownloader
  module Proxies
    # http://tools.rosinstrument.com/proxy/
    # http://tools.rosinstrument.com/proxy/l100.xml
    class RosinstrumentProvider
      def initialize
        @http_client = GBookDownloader::ProxyHttpClient.new
        @feed_url = 'http://tools.rosinstrument.com/proxy/l100.xml'
      end

      def proxy_instances
        return find_proxy_instances(@http_client.get(@feed_url))
      end
      
      def find_proxy_instances(rss)
        return nil unless rss
        proxies = []
        rss_doc = Nokogiri::XML(rss)
        rss_doc.xpath('//item').each do |item|
          doc = Nokogiri::XML(item.to_s)
          proxy = doc.xpath('/item/title').first.text
          desc = doc.xpath('/item/description').first.text
          proxy = proxy.split(':')
          host = proxy.first
          port = proxy.last
          country = desc.split(' ').last
          p = GBookDownloader::Proxies::ProxyInstance.new(host, port)
          p.country = country
          proxies << p
        end

        return proxies
      end
    end
  end
end
