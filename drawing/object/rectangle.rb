module Drawing
  module Object
    class Rectangle
      attr_reader :position, :offset

      MOVE_MENU_FRAMES = 6

      def initialize(x, y, w, h)
        @position = Vector[x, y, w, h]
        @move_frame_count = 0
        @offset = 0.0
        @move_offset = 0.0

        @vertices = [
          Vertex.new(x, y, 1.0),
          Vertex.new(x + w, y, 1.0),
          Vertex.new(x, y + h, 1.0),
          Vertex.new(x + w, y + h, 1.0)
        ]

        @uva = [
          0.0, 1.0,
          1.0, 1.0,
          0.0, 0.0,
          1.0, 0.0
        ]

        @indices = [0, 1, 2, 3]

        @vao = Drawing::VAO.new
        @vao.bind

        @vbo = Drawing::VBO.new(:vertex)
        @vbo.bind
        @vbo.data(vertices_data)
        @vao.set_array_pointer(0, 3, GL_FLOAT, GL_FALSE, 12, 0)

        @vbo_uva = Drawing::VBO.new(:vertex)
        @vbo_uva.bind
        @vbo_uva.data(uva_data)
        @vao.set_array_pointer(1, 2, GL_FLOAT, GL_FALSE, 8, 0)

        @vbo2 = Drawing::VBO.new(:index)
        @vbo2.bind
        @vbo2.data(indices_data)
      end

      def vertices_data
        data = []
        @vertices.each { |v| data.concat v.vector.to_a }
        Data::Float.new(data)
      end

      def uva_data
        Data::Float.new(@uva)
      end

      def indices_data
        Data::UInt.new(@indices)
      end

      def update_vertices(x, y, w, h)
        @vertices = [
          Vertex.new(x, y, 1.0),
          Vertex.new(x + w, y, 1.0),
          Vertex.new(x, y + h, 1.0),
          Vertex.new(x + w, y + h, 1.0)
        ]

        @vbo.bind
        @vbo.sub_data(vertices_data)
      end

      def draw
        @vao.bind
        glDrawElements(GL_TRIANGLE_STRIP, 4, GL_UNSIGNED_INT, 0)
      end

      def move(i)
        @move_frame_count += MOVE_MENU_FRAMES
        @move_offset += i
      end

      def update
        if @move_frame_count > 0
          @move_frame_count -= 1

          if @move_frame_count == 0
             @offset = @move_offset
          else
            delta = [@move_frame_count, MOVE_MENU_FRAMES].min.to_f
            delta_offset = (@move_offset - @offset) * Math.cos(delta / MOVE_MENU_FRAMES.to_f)
            @offset += delta_offset
          end
        end
      end

      def x
        position[0]
      end

      def y
        position[1]
      end

      def width
        position[2]
      end

      def height
        position[3]
      end
    end
  end
end
