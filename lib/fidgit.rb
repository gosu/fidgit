# encoding: utf-8

require 'yaml'

gems = YAML.load(File.read(File.join(File.dirname(__FILE__), 'fidgit', 'gem_dependencies.yml')))

gems.each_pair do |gem, version|
  require gem
end

require_relative 'fidgit/gosu_ext'

require_relative 'fidgit/clipboard'
require_relative 'fidgit/cursor'
require_relative 'fidgit/event'
require_relative 'fidgit/gui_window'
require_relative 'fidgit/history'
require_relative 'fidgit/redirector'
require_relative 'fidgit/selection'
require_relative 'fidgit/thumbnail'

require_relative 'fidgit/states/gui_state'
require_relative 'fidgit/states/message_dialog'

require_relative 'fidgit/elements/button'
require_relative 'fidgit/elements/color_picker'
require_relative 'fidgit/elements/color_well'
require_relative 'fidgit/elements/combo_box'
require_relative 'fidgit/elements/grid_packer'
require_relative 'fidgit/elements/group'
require_relative 'fidgit/elements/horizontal_packer'
require_relative 'fidgit/elements/label'
require_relative 'fidgit/elements/list'
require_relative 'fidgit/elements/radio_button'
require_relative 'fidgit/elements/slider'
require_relative 'fidgit/elements/text_area'
require_relative 'fidgit/elements/toggle_button'
require_relative 'fidgit/elements/tool_tip'
require_relative 'fidgit/elements/vertical_packer'