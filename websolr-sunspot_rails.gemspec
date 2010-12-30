# -*- encoding: utf-8 -*-
VERSION = File.read(File.join(File.dirname(__FILE__), "VERSION"))

Gem::Specification.new do |s|
  s.name = %q{websolr-sunspot_rails}
  s.version = VERSION

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Kyle Maxwell", "John Barnette", "Mat Brown", "Nick Zadrozny"]
  s.date = %q{2010-08-30}
  s.description = %q{websolr to sunspot_rails shim}
  s.email = %q{info@onemorecloud.com}
  s.extra_rdoc_files = [
    "LICENSE",
     "README.rdoc"
  ]
  s.files = [
    ".document",
     ".gitignore",
     "LICENSE",
     "README.rdoc",
     "Rakefile",
     "VERSION",
     "lib/websolr-sunspot_rails.rb",
     "websolr-sunspot_rails.gemspec"
  ]
  s.homepage = %q{http://github.com/onemorecloud/websolr-sunspot_rails}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.6}
  s.summary = %q{websolr to sunspot_rails shim}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<sunspot_rails>, ["= 1.2.1"])
      s.add_development_dependency(%q<rspec>, [">= 0"])
    else
      s.add_dependency(%q<sunspot_rails>, ["= 1.2.1"])
      s.add_dependency(%q<rspec>, [">= 0"])
    end
  else
    s.add_dependency(%q<sunspot_rails>, ["= 1.2.1"])
    s.add_dependency(%q<rspec>, [">= 0"])
  end
end

