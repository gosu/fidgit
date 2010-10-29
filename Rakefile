ROOT = File.expand_path(File.join(__FILE__, '..'))

require_relative 'lib/fidgit/version'

require 'yaml'
require 'rake/clean'
require 'rake/gempackagetask'

CLEAN.include("log/**/*", "doc/**/*")
CLOBBER.include("log/**/*", "doc/**/*")

specification = Gem::Specification.new do |s|
    s.name = "fidgit"
    s.summary = "Fidgit is a GUI library built on Gosu/Chingu"
    s.version = Fidgit::VERSION
    s.date = Time.now.strftime '%Y-%m-%d'
    s.author = "Bil Bas (Spooner)"
    s.email = 'bil.bagpuss@gmail.com'
    s.description = s.summary
    s.require_path = 'lib'
	YAML::load(File.read(File.join(ROOT, 'lib/gem_dependencies.yml'))).each_pair do |gem, version|
		s.add_dependency(gem, version)
	end
    s.platform = Gem::Platform::RUBY
    s.homepage = "http://github.com/Spooner/fidgit/"
    s.has_rdoc = false
    s.extensions = []
    s.files =  ["Rakefile", "README.textile", "COPYING.txt"] +
      FileList["lib/**/*", "config/**/*", "examples/**/*", "media/**/*", "spec/**/*"]
end

Rake::GemPackageTask.new(specification) do |package|
  package.need_zip = false
  package.need_tar = false
end

desc "Run rspec 2.0"
task :rspec do
  system "rspec spec"
end

desc "Create yard docs"
task :doc do
  system "yard doc lib"
end  
