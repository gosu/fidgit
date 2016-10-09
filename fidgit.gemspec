# -*- encoding: utf-8 -*-
$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
require 'fidgit/version'

Gem::Specification.new do |s|
  s.name        = 'fidgit'
  s.version     = Fidgit::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Bil Bas (Spooner)']
  s.email       = ['bil.bagpuss@gmail.com']
  s.homepage    = 'http://github.com/Spooner/fidgit/'
  s.summary     = 'Fidgit is a GUI library built on Gosu/Chingu'
  s.description = 'Fidgit is a GUI library built on Gosu/Chingu'

  s.rubyforge_project = 'fidgit'
  s.has_rdoc = true
  s.required_ruby_version = '>= 1.9.2'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_paths = ['lib']
  s.license       = 'MIT'

  s.add_runtime_dependency('gosu', '~> 0.7', '>= 0.7.41')
  s.add_runtime_dependency('chingu', '~> 0.9rc9')
  s.add_runtime_dependency('clipboard', '~> 0.9', '>= 0.9.9')
  s.add_runtime_dependency('ffi', '~> 1.0', '>= 1.0.11')

  s.add_development_dependency('rspec', '~> 2.8', '>= 2.8.0')
  s.add_development_dependency('texplay', '~> 0.4', '>= 0.4.3')
  s.add_development_dependency('rake', '~> 10.3', '>= 10.3.2')
  s.add_development_dependency('yard', '~> 0.8.7', '>= 0.8.7.4')
  s.add_development_dependency('RedCloth', '~> 4.2', '>= 4.2.9')
end
