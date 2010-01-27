require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "websolr-sunspot_rails"
    gem.summary = %Q{websolr to sunspot_rails shim}
    gem.description = %Q{websolr to sunspot_rails shim}
    gem.email = "kyle@kylemaxwell.com"
    gem.homepage = "http://github.com/fizx/websolr-sunspot_rails"
    gem.authors = ["Kyle Maxwell"]
    gem.add_dependency "plain_option_parser", ">= 0"
    gem.add_dependency "sunspot", "=0.10.8"
    gem.add_dependency "sunspot_rails", "=0.11.5"
    gem.add_dependency "rest-client"
    gem.add_development_dependency "rspec", ">= 0"
  end
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |test|
    test.libs << 'test'
    test.pattern = 'test/**/test_*.rb'
    test.verbose = true
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov"
  end
end

task :test => :check_dependencies

task :default => :test

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "websolr-sunspot_rails #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
