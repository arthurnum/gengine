module Drawing
  module Object
    class Rectangle3D

      def initialize(vertices)
        @vertices = vertices

        @uva = [
          0.0, 0.0,
          1.0, 0.0,
          0.0, 1.0,
          1.0, 1.0
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

      def draw
        @vao.bind
        glDrawElements(GL_TRIANGLE_STRIP, 4, GL_UNSIGNED_INT, 0)
      end
    end
  end
end
