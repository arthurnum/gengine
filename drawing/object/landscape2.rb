module Drawing
  module Object
    class Landscape2
      attr_reader :vertices_data, :indices_data,
                  :vertices

      def initialize(dim)
        puts "Initialize landscape2 object."

        ###
        # generate vertices
        ###
        print "Generate vertices... "
        @vertices = []
        dim.times do |row|
          dim.times do |column|
            @vertices << generate_vertex(row, column)
          end
        end
        puts "Done."

        ###
        # initialize uva index
        ###
        @uva_data = []
        @vertices.each do |vert|
          @uva_data << vert.x / dim.to_f + 0.01
          @uva_data << vert.z / dim.to_f + 0.01
        end

        @indices = generate_indices(dim)

        build_gl_objects
      end

      def draw
        @vao.bind
        glDrawElements(GL_TRIANGLE_STRIP, size, GL_UNSIGNED_INT, 0)
      end

      def vertices_data
        data = []
        @vertices.each { |v| data.concat v.vector.to_a }
        Data::Float.new(data)
      end

      def uva_data
        Data::Float.new(@uva_data)
      end

      def indices_data
        Data::UInt.new(@indices)
      end

      def size
        @indices.size
      end

      def ray_intersect(ray)
        @octree.ray_intersect(ray)
      end

      def focus_array
        @octree.focus_array
      end

      private

      def generate_vertex(row, column)
        x = 1.0 * column
        y = 0.0
        z = 1.0 * row
        Vertex.new(x, y, z)
      end

      # odd -> false     finish -> n*n - 1
      # odd -> true      finish -> n*n - n
      def generate_indices(dim)
        result = []
        finish = dim.odd? ? dim*dim - dim : dim*dim - 1
        right = true
        i = 0
        while i != finish
          if right
            dim.times do
              result << i
              result << i + dim
              i += 1
            end
            i = result.last
          else
            (dim-1).times do
              result << i + dim
              i -= 1
              result << i
            end
            i = i + dim
          end
          right = !right
        end
        result << i if right
        result
      end

      def build_gl_objects
        @vao = Drawing::VAO.new
        @vao.bind

        @supervbo = Drawing::VBO.new(:vertex)
        @supervbo.bind
        @supervbo.data(vertices_data)
        @vao.set_array_pointer(0, 3, GL_FLOAT, GL_FALSE, 0, 0)

        @uva_vbo = Drawing::VBO.new(:vertex)
        @uva_vbo.bind
        @uva_vbo.data(uva_data)
        @vao.set_array_pointer(1, 2, GL_FLOAT, GL_FALSE, 0, 0)

        @vbo2 = Drawing::VBO.new(:index)
        @vbo2.bind
        @vbo2.data(indices_data)
      end
    end
  end
end
