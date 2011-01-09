require 'bundler'
Bundler::GemHelper.install_tasks

require 'yard'
require 'redcloth'

README_HTML = "README.html"
README_TEXTILE = "README.textile"

class EventHandlesHandler < YARD::Handlers::Ruby::Base
  handles method_call(:handles)

  def process
    klass = statement.parent.parent.jump(:const)[0]
    name = statement.method_name(true)
    params = statement.parameters(false).dup
    puts "Processing Event method: #{klass}.#{name} :#{params[0].jump(:ident)[0]}"
  end
end


YARD::Rake::YardocTask.new
task :yard => README_HTML

desc "Convert readme to HTML"
file README_HTML => :readme
task :readme => README_TEXTILE do
  puts "Converting readme to HTML"
  File.open(README_HTML, "w") do |file|
    file.write RedCloth.new(File.read(README_TEXTILE)).to_html
  end
end

# Specs
desc "Run rspec 2.0"
task :rspec do
  system "rspec spec"
end