require 'open-uri'

module GBookDownloader
  class ProxyHttpClient

    def initialize
      @user_agents = []
      File.open(File.dirname(__FILE__) + '/user_agents').each do |line|
        @user_agents << line.chomp
      end
    end

    def get(url, cookie_str=nil, proxy_instance=nil, &block)
      options = {}
      options['User-Agent'] = @user_agents[rand(@user_agents.size)] if(@user_agents.size > 0)
      if proxy_instance
        options['proxy'] = "http://#{proxy_instance.host}:#{proxy_instance.port}" 
      end
      options['Cookie'] = cookie_str if cookie_str
      
      if block_given?
        open(url, options) { |file| yield file }
      else
        open(url, options)
      end
    end
  end
end
