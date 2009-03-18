spec = Gem::Specification.new do |s|
  s.name = 'gbook-downloader'
  s.version = '0.0.1'
  s.date = '2009-03-18'
  s.summary = 'Google Book Downloader'
  s.description = s.summary
  s.email = 'himars@gmail.com'
  s.homepage = "http://github.com/jacktang/gbook-downloader"
  s.has_rdoc = true
  s.authors = ["Jack Tang"]
  s.add_dependency('nokogiri', '>= 1.2.2')
  # s.extensions = ["ext/em_buffer/extconf.rb" , "ext/http11_client/extconf.rb"]

  s.require_path = 'lib'
  s.executables = ['bin/gbd', 'bin/gbook-downloader']

  # ruby -rpp -e' pp `git ls-files`.split("\n") '
  s.files = Dir['lib/**/*.rb'] + Dir['spec/**/*.rb'] + ["LICENSE", "README.rdoc"]
end
