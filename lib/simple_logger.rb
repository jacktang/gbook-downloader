require 'logger'

module GBookDownloader
  module SimpleLogger

    def logger
      l = ::Logger.new($stdout)
      l.level = ::Logger::DEBUG
      return l
    end

  end
end
