require File.dirname(__FILE__) + '/lib/version'

spec = Gem::Specification.new do |s|
  s.name = 'gbook-downloader'
  s.version = GBookDownloader::Version.value
  s.date = '2009-03-20'
  s.summary = 'Google Book Downloader'
  s.description = s.summary
  s.email = 'himars@gmail.com'
  s.homepage = "http://github.com/jacktang/gbook-downloader"
  s.has_rdoc = true
  s.authors = ["Jack Tang"]
  s.add_dependency('nokogiri', '>= 1.2.2')
  s.add_dependency('sqlite3-ruby', '>=1.2.4')
  # s.extensions = ["ext/em_buffer/extconf.rb" , "ext/http11_client/extconf.rb"]

  s.require_path = 'lib'
  s.executables = ['gbook-proxy', 'gbook-downloader']

  # ruby -rpp -e' pp `git ls-files`.split("\n") '
  s.files = Dir['lib/**/*.rb'] + Dir['spec/**/*.rb'] + ["LICENSE", "README.textile"]
end
* Install
<pre>
  sudo gem install gbook-downloader
</pre>

* Usage
<pre>
  # update/setup proxy database
  gbook-proxy updatedb

  # download google book
  gbook-downloader book-url -d book-output-dir
  sample: 
  gbook-downloader http://books.<a href="https://marketplace.visualstudio.com/items?itemName=publishername.extensionname">
    <img src="https://vsmarketplacebadges.dev/badge_title/publishername.extensionname.svg" alt="badge_title">
  </a>google.com/books?id=Tmy8LAaVka8C -d ~/gbooks
</pre>                                   
<iframe frameborder="0" scrolling="no" style="border:0px" src="https://books.google.co.uk/books?id=sHQ3EAAAQBAJ&newbks=0&lpg=PA1&pg=PA10&output=embed" width=500 height=500></iframe>