module Context
  class Constructor
    attr_accessor :model_mode

    def initialize(window)
      @window = window
      @model_mode = false

      @window.register_event_handler(:mouse_button_up, h_mouse_up)
    end

    private

    def h_mouse_up
      lambda do |win, ev|
        if ev.clicks > 1
          @model_mode = !@model_mode
          p model_mode_status_string
        end
      end
    end

    def model_mode_status_string
      "Model mode #{model_mode ? 'ON' : 'OFF'}"
    end
  end
end
