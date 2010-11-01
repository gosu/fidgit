# Run all examples, one after the other
require_relative 'helpers/example_window'


examples = Dir.glob(File.join(File.dirname(__FILE__), "*.rb")) - [__FILE__]
examples.each_with_index do |file_name, index|
  ENV['FIDGIT_EXAMPLES_TEXT'] = "[#{index + 1} of #{examples.size + 1}]"
  `ruby #{file_name}`
end
