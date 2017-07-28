module Context
  class Menu
    PADDING = 20
    HALF_PADDING = 10

    attr_accessor :items, :focus, :font, :position, :item_shader, :focus_shader, :matrix,
                  :window, :network

    def initialize
      @items = []
      @position = Vector[0, 0, 0]
    end

    def add(item)
      items << item
    end

    def setup
      x = position[0]
      y = position[1]
      max_w = 0
      items.each do |item|
        item.texture = Drawing::Texture.new
        item.texture.bind
        w, h = item.texture.print(font, item.title)
        item.rectangle = Drawing::Object::Rectangle.new(x + PADDING, y + PADDING, w, h)
        y += h + PADDING
        max_w = w if w > max_w
      end
      max_h = items[0].height

      @active_item = items.last
      @focus = Drawing::Object::Rectangle.new(x, @active_item.y - HALF_PADDING, max_w + PADDING * 2, max_h + PADDING)

      items_itr = items.each
      item1 = items_itr.next
      loop do
        break unless item2 = items_itr.next

        item1.next = item2
        item1 = item2
      end

      @input_box = InputBox.generate(200, 200, font, "arthurnum")

      @h_menu_switch = lambda do |win, ev|
        if ev.scancode == SDL2::Key::Scan::UP
            if next_item = @active_item.next
              i = next_item.y - @active_item.y
              @focus.move(i)
              @active_item = next_item
            end
          end
        if ev.scancode == SDL2::Key::Scan::DOWN
          if previous_item = @active_item.previous
            i = previous_item.y - @active_item.y
            @focus.move(i)
            @active_item = previous_item
          end
        end
        if ev.scancode == SDL2::Key::Scan::RETURN
          @active_item.submit
        end
      end

      @h_text_input = lambda do |win, ev|
        @input_box.add(font, ev.text)
      end

      @h_text_input_backspace = lambda do |win, ev|
        if ev.scancode == SDL2::Key::Scan::BACKSPACE
          @input_box.chop(font)
        end
        if ev.scancode == SDL2::Key::Scan::DELETE
          turn_off_state_2
          turn_on_state_1
        end
        if ev.scancode == SDL2::Key::Scan::RETURN
          if try_to_log_in
            puts " OK."
            turn_off_state_2
            self.exit
          else
            puts " failed."
          end
        end
      end

      turn_on_state_1
    end

    def draw
      glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)
      glDisable(GL_DEPTH_TEST)
      glEnable(GL_BLEND)
      glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
      glActiveTexture(GL_TEXTURE0)

      item_shader.use
      item_shader.uniform_matrix4(matrix, 'MVP')
      item_shader.uniform_1i("texture1", 0)
      items.each do |item|
        item.texture.bind
        item.rectangle.draw
      end

      @input_box.texture.bind
      @input_box.rectangle.draw

      focus_shader.use
      focus_shader.uniform_matrix4(matrix.translate(0, focus.offset, 0), 'MVP')
      focus_shader.uniform_vector4fv(focus.position, 'rect_info')
      focus.draw

      glDisable(GL_BLEND)
    end

    def update
      focus.update
    end

    def on_exit(&block)
      @exit_callback = block
    end

    def exit
      @exit_callback.call
    end

    def turn_on_state_1
      window.register_event_handler(:key_down, @h_menu_switch)
    end

    def turn_off_state_1
      window.remove_event_handler(:key_down, @h_menu_switch)
    end

    def turn_on_state_2
      SDL2::TextInput.start
      window.register_event_handler(:text_input, @h_text_input)
      window.register_event_handler(:key_down, @h_text_input_backspace)
    end

    def turn_off_state_2
      SDL2::TextInput.stop
      window.remove_event_handler(:text_input, @h_text_input)
      window.remove_event_handler(:key_down, @h_text_input_backspace)
    end

    def try_to_log_in
      login_packet = Network::Protocol::PacketUserLogIn.new
      login_packet.player_name = @input_box.text.chomp
      puts "Try to log in: #{login_packet.player_name}"
      network.write [login_packet]
      tries = 5
      begin
        puts ' wait for response...'
        packages = network.read
        sleep 0.4
        tries -= 1
      end while tries > 0 && !packages

      packages && packages.any? { |pckg| pckg.user_log_in_ok? }
    end
  end
end
