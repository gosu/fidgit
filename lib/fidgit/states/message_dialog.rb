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
        background_color: DEFAULT_BACKGROUND_COLOR,
        border_color: DEFAULT_BORDER_COLOR,
        width: $window.width / 2
      }.merge! options

      @type = options[:type]
      raise ArgumentError, ":type must be one of #{VALID_TYPES}, not #{@type}" unless VALID_TYPES.include? @type

      super()

      pack :vertical, options do
        text_area(text: message, enabled: false, width: options[:width] - padding_x * 2)

        pack :horizontal do
          @type.to_s.split('_').each do |type|
            button(text: options[:"#{type}_text"]) do
              hide
              block.call type.to_sym if block
            end
          end
        end
      end
    end
  end
end