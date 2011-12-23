# -*- encoding: utf-8 -*-
$:.unshift File.expand_path("../lib", __FILE__)
require "fidgit/version"

Gem::Specification.new do |s|
  s.name        = "fidgit"
  s.version     = Fidgit::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Bil Bas (Spooner)"]
  s.email       = ["bil.bagpuss@gmail.com"]
  s.homepage    = "http://github.com/Spooner/fidgit/"
  s.summary     = %q{Fidgit is a GUI library built on Gosu/Chingu}
  s.description = %q{Fidgit is a GUI library built on Gosu/Chingu}

  s.rubyforge_project = "fidgit"
  s.has_rdoc = true
  s.required_ruby_version = "~> 1.9.2"
  
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency('gosu', '~> 0.7.33')
  s.add_dependency('chingu', '~> 0.9rc7')
  s.add_dependency('clipboard', '~> 0.9.9')
  s.add_dependency('ffi', '= 1.0.9') # 1.0.10 is borked :(
  s.add_development_dependency('rspec', '~> 2.1.0')
  s.add_development_dependency('texplay', '~> 0.3.5')
  s.add_development_dependency('rake')
  s.add_development_dependency('yard')
  s.add_development_dependency('RedCloth', "~> 4.2.9")
end
