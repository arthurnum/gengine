module Drawing
  module Object
    class Landscape
      attr_reader :data, :normals, :indices

      def initialize(dim)
        @data = []
        @vertices = []
        @normals = []
        dim.times do |row|
          dim.times do |column|
            @data.concat generate_vertex(row, column)
          end
        end

        @normals = calculate_normals(dim)

        @indices = generate_indices(dim)
      end

      private

      def generate_vertex(row, column)
        x = 0.5 * column
        y = 0.15 * rand
        z = -0.5 * row
        result = Vector[x, y, z]
        @vertices << result
        result.to_a
      end

      def calculate_normals(dim)
        result = []
        faces = []

        (dim-1).times do |row|
          (dim-1).times do |column|
            diff = row * dim + column

            if row.odd?
              v1 = @vertices[diff]
              v2 = @vertices[diff + dim]
              v3 = @vertices[diff + dim + 1]
              faces << face_normal(v1, v2, v3)

              v1 = @vertices[diff + 1]
              v2 = @vertices[diff]
              v3 = @vertices[diff + dim + 1]
              faces << face_normal(v1, v2, v3)
            else
              v1 = @vertices[diff]
              v2 = @vertices[diff + dim]
              v3 = @vertices[diff + 1]
              faces << face_normal(v1, v2, v3)

              v1 = @vertices[diff + 1]
              v2 = @vertices[diff + dim]
              v3 = @vertices[diff + dim + 1]
              faces << face_normal(v1, v2, v3)
            end
          end
        end

        fpr = (dim - 1) * 2
        dim.times do |row|
          dim.times do |column|
            diff = row * dim + column

            if row == 0
              if column == 0
                result.concat vertex_normal(faces[0])
              elsif column == dim - 1
                result.concat vertex_normal(faces[column*2 - 1])
              else
                i = column * 2
                result.concat vertex_normal(faces[i], faces[i - 1], faces[i - 2])
              end
            elsif row == dim - 1
              if column == 0
                t = (row - 1) * fpr
                result.concat (row.odd? ? vertex_normal(faces[t], faces[t + 1]) : vertex_normal(faces[t]))
              elsif column == dim - 1
                t = row * fpr - 1
                result.concat (row.odd? ? vertex_normal(faces[t]) : vertex_normal(faces[t], faces[t - 1]))
              else
                t = (row - 1) * fpr + column * 2
                result.concat (row.odd? ? vertex_normal(faces[t + 1], faces[t], faces[t - 1]) : vertex_normal(faces[t], faces[t - 1], faces[t - 2]))
              end
            else
              if row.odd?
                if diff % dim == 0
                  t = row * fpr
                  b = t - fpr
                  result.concat vertex_normal(faces[t], faces[t + 1], faces[b], faces[b + 1])
                elsif diff % dim == dim - 1
                  t = (row + 1) * fpr - 1
                  b = t - fpr
                  result.concat vertex_normal(faces[t], faces[b])
                else
                  t = row * fpr + column * 2
                  b = t - fpr
                  result.concat vertex_normal(faces[t + 1], faces[t], faces[t - 1],
                                              faces[b + 1], faces[b], faces[b - 1])
                end
              else
                if diff % dim == 0
                  t = row * fpr
                  b = t - fpr
                  result.concat vertex_normal(faces[t], faces[b])
                elsif diff % dim == dim - 1
                  t = (row + 1) * fpr - 1
                  b = t - fpr
                  result.concat vertex_normal(faces[t], faces[t - 1], faces[b], faces[b - 1])
                else
                  t = row * fpr + column * 2
                  b = t - fpr
                  result.concat vertex_normal(faces[t], faces[t - 1], faces[t - 2],
                                              faces[b], faces[b - 1], faces[b - 2])
                end
              end
            end
          end
        end

        result
      end

      def face_normal(v1, v2, v3)
        t1 = v2 - v1
        t2 = v3 - v1
        result = t1.cross_product t2
        result.normalize
      end

      def vertex_normal(*faces)
        result = Vector[0.0, 0.0, 0.0]
        faces.each { |f| result += f }
        result.normalize.to_a
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
