$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
require 'fidgit/version'

Gem::Specification.new do |s|
  s.name        = 'fidgit'
  s.version     = Fidgit::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Bil Bas (Spooner)']
  s.email       = ['bil.bagpuss@gmail.com']
  s.homepage    = 'https://github.com/gosu/fidgit/'
  s.summary     = 'Fidgit is a GUI library built on Gosu/Chingu'
  s.description = 'Fidgit is a GUI library built on Gosu/Chingu'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_paths = ['lib']
  s.license       = 'MIT'

  s.add_runtime_dependency('gosu', '~> 0.7')
  s.add_runtime_dependency('chingu', '~> 0.9rc9')
  s.add_runtime_dependency('clipboard', '~> 0.9')

  s.add_development_dependency('rspec', '~> 2.8')
  s.add_development_dependency('rake', '~> 12.3', '=> 12.3.3')
  s.add_development_dependency('yard', '~> 0.9.11')
  s.add_development_dependency('RedCloth', '~> 4.2', '>= 4.2.9')
end
