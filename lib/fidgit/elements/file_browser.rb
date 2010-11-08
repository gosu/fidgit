# encoding: utf-8

require_relative 'composite'

module Fidgit
  class FileBrowser < Composite
    VALID_TYPES = [:open, :save]

    handles :selected

    attr_reader :pattern, :base_directory

    def show_extension?; @show_extension; end
    def directory; File.join(@base_directory, @directory_label.text); end
    def file_name; @file_name_text.text; end
    def file_path; File.join(directory, file_name); end

    # @param [Symbol] type One of :open, :save
    # @option options [String] :base_directory ('') Outermost directory that the browser will see.
    # @option options [String] :directory (current working directory).
    # @option options [String] :file_name ('') Initially selected file in the directory.
    # @option options [String] :pattern ('*.*')
    # @option options [Boolean] :show_extension (true)
    def initialize(parent, type, options = {})
      options = {
        base_directory: '',
        directory: Dir.pwd,
        file_name: '',
        pattern: '*.*',
        show_extension: true,
        width: 400,
        save_text: "Save",
        open_text: "Open",
        cancel_text: "Cancel",
      }.merge! options

      @type = type
      raise ArgumentError, "type must be one of #{VALID_TYPES}, not #{@type}" unless VALID_TYPES.include? @type

      @pattern = options[:pattern]
      @show_extension = options[:show_extension]
      @base_directory = options[:base_directory]

      relative_directory = options[:directory].sub(/^#{@base_directory}/, '')
      relative_directory = '/' if relative_directory == ''

      super parent, options

      pack :vertical do
        pack :horizontal, padding: 0 do
          @up_button = button(text: "^") do
            unless @directory_label.text.empty?
              directory = File.dirname(@directory_label.text)
              directory = '/' if directory == '.'
              @directory_label.text = directory
              update_files_list
            end
          end

          @directory_label = label relative_directory
        end

        @files_list = list(width: options[:width]) do
          subscribe :changed do |sender, file_path|
            file_name = File.basename file_path
            if File.directory? file_path
              @directory_label.text = File.join(@directory_label.text, file_name)
              update_files_list
            else
              @file_name_text.text = file_name
            end
          end
        end

        @file_name_text = text_area(text: options[:file_name], max_height: font_size * 2, width: options[:width])

        pack :horizontal, align: :center, padding: 0 do
          case @type
            when :open
              button(text: options[:open_text]) do
                publish :selected, :open, file_path
              end
            when :save
              button(text: options[:save_text]) do
                publish :selected, :save, file_path
              end
          end

          button(text: options[:cancel_text]) do
            publish :selected, :cancel, file_path
          end
        end

        update_files_list
      end
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

          @files_list.item file_path, text: file_name, icon: Gosu::Image["file_file.png"]
        end
      end
    end

    protected
    def post_init_block(&block)
      subscribe :selected, &block
    end
  end
end