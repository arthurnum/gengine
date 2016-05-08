module Context
  class Constructor
    attr_accessor :model_mode

    def initialize(window, world)
      @window = window
      @world = world
      @world.constructor = self
      @model_mode = false

      @window.register_event_handler(:key_down, h_model_mode)
      @window.register_event_handler(:mouse_motion, h_mouse_motion)
      @window.register_event_handler(:mouse_wheel, h_mouse_wheel)
    end

    private

    def h_model_mode
      lambda do |win, ev|
        if ev.scancode == SDL2::Key::Scan::O
          @model_mode = !@model_mode
          p model_mode_status_string
        end
      end
    end

    def h_mouse_motion
      lambda do |win, ev|
        @world.matrix.view = @world.matrix.view.translate(ev.xrel*0.05, -ev.yrel*0.05, 0.0) if model_mode
      end
    end

    def h_mouse_wheel
      lambda do |win, ev|
        @world.matrix.view = @world.matrix.view.translate(0.0, 0.0, -ev.y*0.5) if model_mode
      end
    end

    def model_mode_status_string
      "Model mode #{model_mode ? 'ON' : 'OFF'}"
    end
  end
end
