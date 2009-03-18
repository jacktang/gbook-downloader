require 'rubygems'
require 'nokogiri'
require 'json'
require 'proxy_http_client'

module GBookDownloader
  #
  # Collect page in every book preview
  #
  class PageCollector

    attr_reader :proxy_instance
    attr_reader :book
    attr_reader :dest_dir
    attr_reader :downloaded_page_count
    
    def initialize(book, dest_dir)
      @book = book
      @dest_dir = dest_dir
      @downloaded_page_count = 0
      @http_client = GBookDownloader::ProxyHttpClient.new
    end

    def adopt_proxy(proxy_instance)
      @proxy_instance = proxy_instance
    end

    def main_script(book)
      preview_doc = Nokogiri::HTML(@http_client.get(book.preview_url, @preview_cookie, @proxy_instance))
      return preview_doc.xpath('//script').last.content 
    end

    def collect
      begin
        preview_url = @book.preview_url
        @preview_cookie = get_cookie(preview_url, @proxy_instance)
        load_script = main_script(@book)
        pid_prefix = prefix_in_preview(load_script)
      rescue Exception => e
        retry
      end

      process_pids = [] 
      # we only process the page whose src is null
      pids_in_preview(load_script).each do |pid|
        if(@book.pages[pid].nil? || @book.pages[pid][0].nil?) # 'src' is nil
          process_pids << pid
        end
      end

      process_pids.each do |pid|
        puts "process page #{pid.inspect}"

        purl = page_url(pid_prefix, pid)
        
        download_queue = {}
        json_response = @http_client.get(purl, @preview_cookie, @proxy_instance) do |f|
          json_response = f.read
          json_object = JSON.parse(json_response)
          pages = json_object["page"]
          pages.each do |page|
            pid = page["pid"]
            src = page["src"]
            order = page["order"]
            if(pid && !@book.pages.has_key?(pid))
              @book.pages[pid] = []
            end
            if(src && @book.pages[pid][0].nil?)
              @book.pages[pid][0] = src.gsub(/x26/,'&')
              download_queue[pid] = src if @book.pages[pid][1].nil?
            end
            if(order)
              index = order.to_i
              @book.page_order[index] = pid
            end
          end
        end
        download_pages(download_queue, @dest_dir)
        sleep 2
      end
    end


    def download_pages(download_queue, dest_dir)
      download_queue.each do |pid, src|
        @http_client.get(src, @preview_cookie, @proxy_instance) do |page|
          # TODO: content-type auto recogization
          open("#{dest_dir}/#{@book.book_id}/#{pid}.jpg", "wb") do |local_file|
            local_file.write(page.read)
            @book.page[pid][1] = File.expand_path(local_file.path)
          end
        end
      end
    end

    def get_cookie(entry_url, proxy_instance)
      cookie = Hash.new
      @http_client.get(entry_url, nil, proxy_instance){|f| f.meta }['set-cookie'].scan(/([a-zA-Z_-]+)=([^;\s]+);/){
        cookie[$1]=$2
      }
      return cookie.map{|x|x.join('=')}.join('; ')
    end

    def page_url(prefix, pid, sig='')
      return "#{prefix}&pg=#{pid}&sig=#{sig}&jscmd=click3"
    end

    def prefix_in_preview(str)
      regexp = Regexp.compile('"prefix":"([^"]+)"')
      # puts "#{str.inspect}"
      "document.getElementById('content_ads_content').style.display ='';"
      matches = regexp.match(str)
      puts "===> #{matches.inspect}"
      return matches[1].gsub(/\\x26/,'&')
    end


    def pids_in_preview(str)
      regexp = Regexp.compile('"pid":"([^"]+)","src"')
      match = regexp.match(str)
      first_pid = match[1]

      pids = []
      pids << first_pid

      regex = Regexp.compile('\{"pid":"([^"]+)"\}')
      purl = page_url(prefix_in_preview(str), first_pid)      
      response_body = @http_client.get(purl, @preview_cookie, @proxy_instance) do |response|
        response_body = response.read
        matches = response_body.scan(regex)
        matches.each do |match|
          pids << match.first
        end
      end

      pids.uniq!
      return pids
    end

  end
end
