# encoding: utf-8

require 'yaml'

gems = YAML.load(File.read(File.join(File.dirname(__FILE__), 'gem_dependencies.yml')))

gems.each_pair do |gem, version|
  require gem
end

require_relative 'fidgit/gosu_ext'

require_relative 'fidgit/button'
require_relative 'fidgit/clipboard'
require_relative 'fidgit/color_picker'
require_relative 'fidgit/color_well'
require_relative 'fidgit/combo_box'
require_relative 'fidgit/cursor'
require_relative 'fidgit/grid_packer'
require_relative 'fidgit/gui_state'
require_relative 'fidgit/history'
require_relative 'fidgit/horizontal_packer'
require_relative 'fidgit/icon'
require_relative 'fidgit/label'
require_relative 'fidgit/list'
require_relative 'fidgit/radio_button'
require_relative 'fidgit/selection'
require_relative 'fidgit/slider'
require_relative 'fidgit/text_area'
require_relative 'fidgit/toggle_button'
require_relative 'fidgit/tool_tip'
require_relative 'fidgit/vertical_packer'