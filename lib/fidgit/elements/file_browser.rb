module Fidgit
  class FileBrowser < Composite
    VALID_TYPES = [:open, :save]

    event :selected

    attr_reader :pattern, :base_directory

    def show_extension?; @show_extension; end
    def directory
      dir = File.join(*@directories)
      dir = File.join(@base_directory, dir) unless @base_directory.empty?
      dir
    end
    def file_name; @file_name_text.text; end
    def file_path; File.join(directory, file_name); end

    # @param [Symbol] type One of :open, :save
    # @option options [String] :base_directory ('') Outermost directory that the browser will see.
    # @option options [String] :directory (current working directory).
    # @option options [String] :file_name ('') Initially selected file in the directory.
    # @option options [String] :pattern ('*.*')
    # @option options [Boolean] :show_extension (true)
    def initialize(type, options = {})
      options = {
        base_directory: '',
        directory: Dir.pwd,
        file_name: '',
        pattern: default(:pattern),
        show_extension: default(:show_extension),
        width: 400,
        save_text: "Save",
        open_text: "Open",
        cancel_text: "Cancel",
      }.merge! options

      @type = type
      raise ArgumentError, "type must be one of #{VALID_TYPES}, not #{@type}" unless VALID_TYPES.include? @type

      @pattern = options[:pattern]
      @show_extension = options[:show_extension]
      @base_directory = options[:base_directory].chomp File::SEPARATOR

      @directories = options[:directory].sub(/^#{@base_directory}/, '').split(File::SEPARATOR)
      if @directories.first == ''
        @directories[0] = File::SEPARATOR
      end

      super options

      vertical do
        @nav_buttons = horizontal padding: 0, spacing: 2

        @scroll_window = scroll_window(height: 250, width: options[:width]) do
          @files_list = list(width: options[:width]) do
            subscribe :changed do |sender, file_path|
              if file_path
                file_name = File.basename file_path
                if File.directory? file_path
                  @directories.push file_name
                  create_nav_buttons
                  update_files_list
                else
                  @file_name_text.text = file_name
                end
              end
            end
          end
        end

        @file_name_text = text_area(text: options[:file_name], max_height: font.height * 1.5, width: options[:width], border_thickness: 1)

        create_nav_buttons

        horizontal align: :center, padding: 0 do
          @action_button = button(options[:"#{type}_text"]) do
            publish :selected, @type, file_path
          end

          button(options[:cancel_text]) do
            publish :selected, :cancel, file_path
          end
        end

        # Ensure that the open/save button is enabled only when the path is sensible.
        @file_name_text.subscribe :changed do |sender, text|
          @action_button.enabled = case @type
          when :open
            File.exists? file_path and not File.directory? file_path
          when :save
            not text.empty?
          end
        end

        update_files_list
      end
    end

    protected
    def create_nav_buttons(size = @directories.size)
      @nav_buttons.clear

      @directories = @directories[0..size]

      @directories.each_with_index do |dir, i|
        if i < @directories.size - 1
          @nav_buttons.button(dir) do
            create_nav_buttons(i)
          end
        else
          @nav_buttons.label dir, border_color: @@schema.default(Button, :border_color), border_thickness: @@schema.default(Button, :border_thickness)
        end
      end

      update_files_list
    end

    protected
    def update_files_list
      @files_list.clear
      @file_name_text.text = ''
      @scroll_window.offset_x = @scroll_window.offset_y = 0

      # Add folders.
      Dir.glob(File.join(directory, "*")).each do |file_path|
        if File.directory? file_path
          @files_list.item File.basename(file_path), file_path, icon: Gosu::Image["file_directory.png"]
        end
      end

      # Add files that match the pattern.
      Dir.glob(File.join(directory, pattern)).each do |file_path|
        unless File.directory? file_path
          file_name = if @show_extension
                        File.basename(file_path)
                      else
                        File.basename(file_path, File.extname(file_path))
                      end

          @files_list.item file_name, file_path, icon: Gosu::Image["file_file.png"]
        end
      end
    end

    protected
    def post_init_block(&block)
      subscribe :selected, &block
    end
  end
end