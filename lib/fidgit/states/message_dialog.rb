require_relative 'dialog_state'


module Fidgit
  # A dialog that
  class MessageDialog < DialogState
    VALID_TYPES = [:ok, :ok_cancel, :yes_no_cancel]

    attr_reader :type

    # @param [String] message
    #
    # @option options [Symbol] :type (:ok) One from :ok, :ok_cancel, :yes_no_cancel
    # @option options [String] :ok_text ("OK")
    # @option options [String] :yes_text ("Yes")
    # @option options [String] :no_text ("No")
    # @option options [String] :cancel_text ("Cancel")
    #
    # @yield when the dialog is closed.
    # @yieldparam [Symbol] result :ok, :yes, :no or :cancel, depending on the button pressed.
    def initialize(message, options = {}, &block)
      options = {
        type: :ok,
        ok_text: "OK",
        yes_text: "Yes",
        no_text: "No",
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
          if [:ok, :ok_cancel].include? @type
            button text: options[:ok_text] do
              hide
              block.call :ok if block
            end
          end

          if [:yes_no_cancel].include? @type
            button text: options[:yes_text] do
              hide
              block.call :yes if block
            end

            button text: options[:no_text] do
              hide
              block.call :no if block
            end
          end

          if [:yes_no_cancel, :ok_cancel].include? @type
            button text: options[:cancel_text] do
              hide
              block.call :cancel if block
            end
          end
        end
      end
    end
  end
end