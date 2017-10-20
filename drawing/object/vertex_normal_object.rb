module Drawing
  module Object
    class VertexNormalObject

      def self.load(file_name)
        bin_data = File.binread(file_name)
        elements_count, *data = bin_data.unpack('I F*')
        new(elements_count, data)
      end

      def initialize(elements_count, data)
        @elements_count = elements_count
        @position = Vector[2.0, 21.0, 2.0]

        @vao = Drawing::VAO.new
        @vao.bind

        @vbo = Drawing::VBO.new(:vertex)
        @vbo.bind
        @vbo.data(Data::Float.new(data))
        @vao.set_array_pointer(0, 3, GL_FLOAT, GL_FALSE, 24, 0)
        @vao.set_array_pointer(1, 3, GL_FLOAT, GL_FALSE, 24, 12)
      end

      def draw
        @vao.bind
        glDrawArrays(GL_TRIANGLES, 0, @elements_count)
        # glDrawElements(GL_TRIANGLE_STRIP, @elements_count, GL_UNSIGNED_INT, 0)
      end

      def x
        @position[0]
      end

      def y
        @position[1]
      end

      def z
        @position[2]
      end

    end
  end
end
