require 'open-uri'

module OpenURI
  # Most of the code is copied from open-uri
  def self.open_loop(uri, options)
    proxy = options.fetch('proxy', nil) || options.fetch(:proxy, nil)
    http_proxy = URI.parse(proxy) if proxy
    uri_set = {}
    buf = nil
    while true
      redirect = catch(:open_uri_redirect) {
        buf = Buffer.new
        uri.buffer_open(buf, http_proxy, options)
        nil
      }
      if redirect
        if redirect.relative?
          # Although it violates RFC2616, Location: field may have relative
          # URI.  It is converted to absolute URI using uri as a base URI.
          redirect = uri + redirect
        end
        unless redirectable?(uri, redirect)
          raise "redirection forbidden: #{uri} -> #{redirect}"
        end
        if options.include? :http_basic_authentication
          # send authentication only for the URI directly specified.
          options = options.dup
          options.delete :http_basic_authentication
        end
        uri = redirect
        raise "HTTP redirection loop: #{uri}" if uri_set.include? uri.to_s
        uri_set[uri.to_s] = true
      else
        break
      end
    end
    io = buf.io
    io.base_uri = uri
    io
  end
end


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

      begin
        if block_given?
          open(url, options) { |file| yield file }
        else
          open(url, options)
        end
      rescue OpenURI::HTTPError => error
        status = error.io.status[0] # => 3xx, 4xx, or 5xx
        # the_error.message is the numeric code and text in a string
        puts "Ops got a bad status code #{error.message} during processing #{url.inspect}"
      end
    end
  end
end
