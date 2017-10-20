module Drawing
  class World
    class MatrixList
      attr_accessor :projection, :view, :model

      def initialize
        @projection = @view = @model = Drawing::Matrix.identity(4)
        @stack = {
          projection: [],
          view: [],
          model: []
        }
      end

      def push(matrix_type)
        case matrix_type
        when :projection
          @stack[:projection].push projection.clone
        when :view
          @stack[:view].push view.clone
        when :model
          @stack[:model].push model.clone
        end
      end

      def pop(matrix_type)
        case matrix_type
        when :projection
          self.projection = @stack[:projection].pop
        when :view
          self.view = @stack[:view].pop
        when :model
          self.model = @stack[:model].pop
        end
      end

      def world
        projection * view * model
      end
    end

    attr_accessor :matrix, :constructor, :camera

    def initialize
      @matrix = MatrixList.new
    end

    def model_mode?
      constructor.model_mode
    end
  end
end
