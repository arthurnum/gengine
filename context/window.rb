module Context
  class Window
    WINDOW_MODE = SDL2::Window::Flags::OPENGL | SDL2::Window::Flags::RESIZABLE

    class Event
      attr_accessor :handlers

      def initialize
        @handlers = []
      end

      def trigger(win, ev)
        @handlers.each { |handler| handler.call(win, ev) }
      end
    end

    def initialize(w, h, window = true)
      @width = w
      @height = h

      @sdl_window = SDL2::Window.create('GENGINE', 0, 0, w, h, WINDOW_MODE) if window

      @events = {
        key_down: Event.new,
        window: Event.new,
        mouse_button_down: Event.new,
        mouse_button_up: Event.new,
        mouse_motion: Event.new,
        mouse_wheel: Event.new,
        text_input: Event.new
      }
      @exit_mode = false
    end

    def width
      @width
    end

    def height
      @height
    end

    def sdl_window
      @sdl_window
    end

    def gl_swap
      @sdl_window.gl_swap
    end

    def register_event_handler(event, handler)
      @events[event].handlers << handler
    end

    def remove_event_handler(event, handler)
      @events[event].handlers.delete(handler)
    end

    def exit
      @exit_mode = true
    end

    def exit?
      @exit_mode
    end

    def events_poll
      while ev = SDL2::Event.poll
        if SDL2::Event::KeyDown === ev
          @events[:key_down].trigger(self, ev)
        end

        if SDL2::Event::Window === ev
          @events[:window].trigger(self, ev)
        end

        if SDL2::Event::MouseButtonDown === ev
          @events[:mouse_button_down].trigger(self, ev)
        end

        if SDL2::Event::MouseButtonUp === ev
          @events[:mouse_button_up].trigger(self, ev)
        end

        if SDL2::Event::MouseMotion === ev
          @events[:mouse_motion].trigger(self, ev)
        end

        if SDL2::Event::MouseWheel === ev
          @events[:mouse_wheel].trigger(self, ev)
        end

        if SDL2::Event::TextInput === ev
          @events[:text_input].trigger(self, ev)
        end
      end
    end
  end
end
