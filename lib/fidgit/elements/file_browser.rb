# encoding: utf-8

require_relative 'composite'

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

      pack :vertical do
        @nav_buttons = pack :horizontal, padding: 0, spacing: 2

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

        @file_name_text = text_area(text: options[:file_name], max_height: font_size * 2, width: options[:width])

        create_nav_buttons

        pack :horizontal, align: :center, padding: 0 do
          case @type
            when :open
              button(options[:open_text]) do
                publish :selected, :open, file_path
              end
            when :save
              button(options[:save_text]) do
                publish :selected, :save, file_path
              end
          end

          button(options[:cancel_text]) do
            publish :selected, :cancel, file_path
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
          @nav_buttons.label dir, border_color: @@schema.default(Button, :border_color)
        end
      end

      update_files_list
    end

    protected
    def update_files_list
      @files_list.clear
      @file_name_text.text = ''

      # Add folders.
      Dir.glob(File.join(directory, "*")).each do |file_path|
        if File.directory? file_path
          @files_list.item file_path, text: File.basename(file_path), icon: Gosu::Image["file_directory.png"]
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