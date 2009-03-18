begin
  require 'spec'
rescue LoadError
  require 'rubygems'
  gem 'rspec'
  require 'spec'
end

$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__) + "/../lib"))
require 'book'
require 'downloader'
require 'page_collector'
require 'book_weaver'
