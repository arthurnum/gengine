module Context
  class Menu
    PADDING = 20
    HALF_PADDING = 10

    attr_accessor :items, :focus, :font, :position, :item_shader, :focus_shader, :matrix, :window

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
      max_h = items[0].rectangle.height

      @active_item = items.last
      @focus = Drawing::Object::Rectangle.new(x, @active_item.rectangle.position[1] - HALF_PADDING, max_w + PADDING * 2, max_h + PADDING)

      items_itr = items.each
      item1 = items_itr.next
      loop do
        break unless item2 = items_itr.next

        item1.next = item2
        item1 = item2
      end

      window.register_event_handler(:key_down, lambda do |win, ev|
          if ev.scancode == SDL2::Key::Scan::UP
            if next_item = @active_item.next
              i = next_item.rectangle.position[1] - @active_item.rectangle.position[1]
              @focus.move(i)
              @active_item = next_item
            end
          end
          if ev.scancode == SDL2::Key::Scan::DOWN
            if previous_item = @active_item.previous
              i = previous_item.rectangle.position[1] - @active_item.rectangle.position[1]
              @focus.move(i)
              @active_item = previous_item
            end
          end
          if ev.scancode == SDL2::Key::Scan::RETURN
            @active_item.submit
          end
        end
      )
    end

    def draw
      glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)
      glDisable(GL_DEPTH_TEST)
      glEnable(GL_BLEND)
      glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)

      item_shader.use
      item_shader.uniform_matrix4(matrix, 'MVP')
      items.each do |item|
        glActiveTexture(GL_TEXTURE0)
        item.texture.bind
        item_shader.uniform_1i("texture1", 0)
        item.rectangle.draw
      end

      focus_shader.use
      focus_shader.uniform_matrix4(matrix.translate(0, focus.offset, 0), 'MVP')
      focus_shader.uniform_vector4fv(focus.position, 'rect_info')
      focus.draw

      glDisable(GL_BLEND)
    end

    def update
      focus.update
    end

  end
end
