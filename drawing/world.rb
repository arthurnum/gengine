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

    attr_accessor :matrix, :constructor

    def initialize
      @matrix = MatrixList.new
    end

    def model_mode?
      constructor.model_mode
    end
  end
end
