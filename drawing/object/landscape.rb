module Drawing
  module Object
    class Landscape
      attr_reader :vertices_data, :normals_data, :indices_data, :faces,
                  :vertices

      def initialize(dim)
        puts "Initialize landscape object."

        ###
        # generate octree
        ###
        print "Generate octree... "
        @octree = Calculating::Octree.new
        @octree.build_by(dim: dim, voxel_size: 10.0)
        puts "Done."

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
        # generate triangle faces
        ###
        print "Generate triangle faces... \r"
        @faces = []
        (dim-1).times do |row|
          print "Generate triangle faces... (#{row}/#{dim})\r"
          (dim-1).times do |column|
            diff = row * dim + column

            if row.odd?
              v1 = @vertices[diff]
              v2 = @vertices[diff + dim]
              v3 = @vertices[diff + dim + 1]
              @faces << Triangle.new(v1, v2, v3)
              @octree.add_face(@faces.last)

              v1 = @vertices[diff + 1]
              v2 = @vertices[diff]
              v3 = @vertices[diff + dim + 1]
              @faces << Triangle.new(v1, v2, v3)
              @octree.add_face(@faces.last)
            else
              v1 = @vertices[diff]
              v2 = @vertices[diff + dim]
              v3 = @vertices[diff + 1]
              @faces << Triangle.new(v1, v2, v3)
              @octree.add_face(@faces.last)

              v1 = @vertices[diff + 1]
              v2 = @vertices[diff + dim]
              v3 = @vertices[diff + dim + 1]
              @faces << Triangle.new(v1, v2, v3)
              @octree.add_face(@faces.last)
            end
          end
        end
        puts "Generate triangle faces... (#{dim}/#{dim}) Done."

        ###
        # generate normals
        ###
        print "Generate normals... "
        @normals = []
        @vertices.each { |v| @normals << v.normal }
        puts "Done."

        ###
        # initialize uva index
        ###
        @vertices.each do |vert|
          vert.uva = 1.0
        end

        @indices = generate_indices(dim)
      end

      def vertices_data
        data = []
        @vertices.each { |v| data.concat v.vector.to_a }
        Data::Float.new(data)
      end

      def normals_data
        data = []
        @vertices.each { |n| data.concat n.normal.to_a }
        Data::Float.new(data)
      end

      def vn_data
        data = []
        @vertices.each do |vert|
          data.concat vert.vector.to_a
          data.concat vert.normal.to_a
        end
        Data::Float.new(data)
      end

      def uva_data
        data = []
        @vertices.each do |vert|
          data << vert.uva
        end
        Data::Float.new(data)
      end

      def colors_data
        data = []
        @vertices.each { |v| data.concat v.color.to_a }
        Data::Float.new(data)
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
    end
  end
end
