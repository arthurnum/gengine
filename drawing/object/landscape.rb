module Drawing
  module Object
    class Landscape
      attr_reader :data, :indices

      def initialize(dim)
        @data = []
        dim.times do |row|
          dim.times do |column|
            @data.concat generate_vertex(row, column)
          end
        end

        @indices = generate_indices(dim)
      end

      private

      def generate_vertex(row, column)
        x = 0.1 * column
        y = 0.0
        z = -0.1 * row
        [x, y, z]
      end

      # odd -> true     finish -> n*n - 1
      # odd -> false    finish -> n*n - n
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
