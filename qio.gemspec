# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "qio/version"

Gem::Specification.new do |s|
  s.name        = "qio"
  s.version     = QIO::VERSION
  s.authors     = ["Chris Johnson"]
  s.email       = ["chris@kindkid.com"]
  s.homepage    = "https://github.com/kindkid/qio"
  s.summary     = "IO facade, backed by a queue."
  s.description = s.summary

  s.rubyforge_project = "qio"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency "rspec", "~> 2.9.0"
  s.add_development_dependency "simplecov", "~> 0.6.1"
  s.add_development_dependency("rb-fsevent", "~> 0.9.0") if RUBY_PLATFORM =~ /darwin/i
  s.add_development_dependency "guard", "~> 1.0.1"
  s.add_development_dependency "guard-bundler", "~> 0.1.3"
  s.add_development_dependency "guard-rspec", "~> 0.6.0"
end
