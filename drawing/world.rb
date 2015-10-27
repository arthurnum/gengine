module Drawing
  class World
    class MatrixList
      attr_accessor :projection, :view, :model

      def initialize
        @projection = @view = @model = Drawing::Matrix.identity(4)
      end

      def world
        projection * view * model
      end
    end

    attr_accessor :matrix

    def initialize
      @matrix = MatrixList.new
    end
  end
end
