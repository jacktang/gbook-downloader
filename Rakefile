require 'rake'
require 'rake/clean'
require 'rake/rdoctask'
require 'rake/gempackagetask'
require 'spec/rake/spectask'

spec = Gem::Specification.load(File.join(File.dirname(__FILE__), 'gbook-downloader.gemspec'))

desc 'Run all specs in spec directory'
Spec::Rake::SpecTask.new(:spec) do |t|
  t.spec_opts = ['--options', "\"spec/spec.opts\""]
  t.spec_files = FileList['spec/**/*/*_spec.rb']
end

desc 'Build rdoc'
Rake::RDocTask.new(:rdoc) do |task|
  task.rdoc_dir = 'doc'
  task.title    = 'Google Book Downloader'
  task.options = %w(--title GBookDownloader --main README --line-numbers)
  task.rdoc_files.include(['lib/**/*.rb'])
  task.rdoc_files.include(['README', 'LICENSE'])
end



# Default Rake task is compile
# task :default => :compile

desc "If you're building from sources, run this task first to setup the necessary dependencies"
task 'setup' do
  windows = Config::CONFIG['host_os'] =~ /windows|cygwin|bccwin|cygwin|djgpp|mingw|mswin|wince/i
  rb_bin = File.expand_path(Config::CONFIG['ruby_install_name'], Config::CONFIG['bindir'])
  spec.dependencies.select { |dep| Gem::SourceIndex.from_installed_gems.search(dep).empty? }.each do |missing|
    dep = Gem::Dependency.new(missing.name, missing.version_requirements)
    spec = Gem::SourceInfoCache.search(dep, true, true).last
    fail "#{dep} not found in local or remote repository!" unless spec
    puts "Installing #{spec.full_name} ..."
    args = [rb_bin, '-S', 'gem', 'install', spec.name, '-v', spec.version.to_s]
    args.unshift('sudo') unless windows || ENV['GEM_HOME']
    sh args.map{ |a| a.inspect }.join(' ')
  end
end

gem = Rake::GemPackageTask.new(spec) do |pkg|
  pkg.need_tar = true
  pkg.need_zip = true
end

desc "Install the package locally"
task 'install'=>['setup','package'] do |task|
  rb_bin = File.expand_path(Config::CONFIG['ruby_install_name'], Config::CONFIG['bindir'])
  args = [rb_bin, '-S', 'gem', 'install', "pkg/#{spec.name}-#{spec.version}.gem"]
  windows = Config::CONFIG['host_os'] =~ /windows|cygwin|bccwin|cygwin|djgpp|mingw|mswin|wince/i
  args.unshift('sudo') unless windows || ENV['GEM_HOME']
  cmd = args.map{|a| a.inspect}.join(' ')
  sh cmd
end
 
desc "Uninstall previously installed packaged"
task 'uninstall' do |task|
  rb_bin = File.expand_path(Config::CONFIG['ruby_install_name'], Config::CONFIG['bindir'])
  args = [rb_bin, '-S', 'gem', 'install', spec.name, '-v', spec.version.to_s]
  windows = Config::CONFIG['host_os'] =~ /windows|cygwin|bccwin|cygwin|djgpp|mingw|mswin|wince/i
  args.unshift('sudo') unless windows || ENV['GEM_HOME']
  sh args.map{ |a| a.inspect }.join(' ')
end
