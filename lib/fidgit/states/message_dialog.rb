require_relative 'dialog_state'


module Fidgit
  # A simple dialog that manages a message with a set of buttons beneath it.
  class MessageDialog < DialogState
    VALID_TYPES = [:ok, :ok_cancel, :yes_no, :yes_no_cancel, :quit_cancel, :quit_save_cancel]

    attr_reader :type

    # @param [String] message
    #
    # @option options [Symbol] :type (:ok) One from :ok, :ok_cancel, :yes_no, :yes_no_cancel, :quit_cancel or :quit_save_cancel
    # @option options [String] :ok_text ("OK")
    # @option options [String] :yes_text ("Yes")
    # @option options [String] :no_text ("No")
    # @option options [String] :cancel_text ("Cancel")
    # @option options [String] :save_text ("Save")
    # @option options [String] :quit_text ("Quit")
    # @option options [Boolean] :show (true) Whether to show the message immediately (otherwise need to use #show later).
    #
    # @yield when the dialog is closed.
    # @yieldparam [Symbol] result :ok, :yes, :no, :quit, :save or :cancel, depending on the button pressed.
    def initialize(message, options = {}, &block)
      options = {
        type: :ok,
        ok_text: "OK",
        yes_text: "Yes",
        no_text: "No",
        quit_text: "Quit",
        save_text: "Save",
        cancel_text: "Cancel",
        show: true,
        background_color: DEFAULT_BACKGROUND_COLOR,
        border_color: DEFAULT_BORDER_COLOR,
        width: $window.width / 2
      }.merge! options

      @type = options[:type]
      raise ArgumentError, ":type must be one of #{VALID_TYPES}, not #{@type}" unless VALID_TYPES.include? @type

      super(options)

      # Dialog is forced to the centre.
      options[:align_h] = options[:align_v] = :center

      pack :vertical, options do
        text_area(text: message, enabled: false, width: options[:width] - padding_left - padding_right)

        pack :horizontal, align_h: :center do
          @type.to_s.split('_').each do |type|
            button(options[:"#{type}_text"]) do
              hide
              block.call type.to_sym if block
            end
          end
        end
      end

      show if options[:show]
    end
  end
end