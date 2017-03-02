module Drawing
  module Object
    class Cube

      def initialize(x, y, z, w)
        @vertices = [
          Vertex.new(x + w, y + w, z + w),
          Vertex.new(x - w, y + w, z + w),
          Vertex.new(x + w, y + w, z - w),
          Vertex.new(x - w, y + w, z - w),
          Vertex.new(x + w, y - w, z + w),
          Vertex.new(x - w, y - w, z + w),
          Vertex.new(x - w, y - w, z - w),
          Vertex.new(x + w, y - w, z - w)
        ]

        @indices = [
          3, 2, 6,
          7, 4, 2,
          0, 3, 1,
          6, 5, 4,
          1, 0
        ]

        @vao = Drawing::VAO.new
        @vao.bind

        @vbo = Drawing::VBO.new(:vertex)
        @vbo.bind
        @vbo.data(vertices_data)
        @vao.set_array_pointer(0, 3, GL_FLOAT, GL_FALSE, 12, 0)

        @vbo2 = Drawing::VBO.new(:index)
        @vbo2.bind
        @vbo2.data(indices_data)
      end

      def vertices_data
        data = []
        @vertices.each { |v| data.concat v.vector.to_a }
        Data::Float.new(data)
      end

      def indices_data
        Data::UInt.new(@indices)
      end

      def draw
        @vao.bind
        glDrawElements(GL_TRIANGLE_STRIP, 14, GL_UNSIGNED_INT, 0)
      end

    end
  end
end
