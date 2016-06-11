module Context
  class Constructor
    attr_accessor :model_mode, :shift_radius

    def initialize(window, world)
      @window = window
      @world = world
      @world.constructor = self
      @model_mode = false
      @shift_radius = 5.0

      @window.register_event_handler(:key_down, h_shift_radius)
      @window.register_event_handler(:key_down, h_model_mode)
      @window.register_event_handler(:mouse_motion, h_mouse_motion)
      @window.register_event_handler(:mouse_wheel, h_mouse_wheel)
    end

    private

    def h_shift_radius
      lambda do |win, ev|
        @shift_radius = case ev.scancode
        when SDL2::Key::Scan::K1
          1.0
        when SDL2::Key::Scan::K2
          2.0
        when SDL2::Key::Scan::K3
          3.0
        when SDL2::Key::Scan::K4
          4.0
        when SDL2::Key::Scan::K5
          5.0
        when SDL2::Key::Scan::K6
          6.0
        when SDL2::Key::Scan::K7
          7.0
        else
          @shift_radius
        end
      end
    end

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
        if model_mode
          @world.camera.rotate(ev.xrel / 4.0)
          @world.camera.move(ev.yrel / 4.0)
          @world.matrix.view = @world.camera.view
        end
      end
    end

    def h_mouse_wheel
      lambda do |win, ev|
        @world.camera.move_y(-ev.y / 4.0)
        @world.matrix.view = @world.camera.view
      end
    end

    def model_mode_status_string
      "Model mode #{model_mode ? 'ON' : 'OFF'}"
    end
  end
end
