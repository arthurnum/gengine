module Context
  class WindowCallbacks
    @@h_escape = lambda do |win, ev|
      win.exit if ev.scancode == SDL2::Key::Scan::ESCAPE
    end

    @@h_resized = lambda do |win, ev|
      p 'Augh! RESIZED!'
    end

    def self.init(window)
      window.register_event_handler(:key_down, @@h_escape)
      window.register_event_handler(:window, @@h_resized)
    end
  end
end
