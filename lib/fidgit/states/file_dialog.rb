module Fidgit
  # A simple dialog that manages a message with a set of buttons beneath it.
  class FileDialog < DialogState
    def initialize(type, options = {}, &block)
      options = {
        show: true,
        background_color: DEFAULT_BACKGROUND_COLOR,
        border_color: DEFAULT_BORDER_COLOR,
      }.merge! options

      super(options)

      pack :vertical, align: :center, padding: 0 do |packer|
        FileBrowser.new(type, { parent: packer }.merge!(options)) do |sender, result, file_name|
          hide
          block.call result, file_name if block
        end
      end

      show if options[:show]
    end
  end
end

