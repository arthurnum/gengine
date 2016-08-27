module Drawing
  class CameraZ
    FLEE_POINT = Vector[0.0, 0.0, -1.0]
    ORIGIN_POINT = Vector[0.0, 0.0, 0.0]

    attr_reader :view

    def initialize
      @stack = []
      @position = ORIGIN_POINT
      @view = Drawing::Matrix.look_at(@position, Vector[0.0, 0.0, 10.0], Vector[0.0, 1.0, 0.0])
    end

    def flee
      @is_flee, @is_return = true, false
    end

    def return
      @is_flee, @is_return = false, true
    end

    def update
      if @is_flee
        args = (FLEE_POINT - @position).r
        @position -= Vector[0, 0, Math.sin(args) * 0.1]
        @view = Drawing::Matrix.look_at(@position, Vector[0.0, 0.0, 10.0], Vector[0.0, 1.0, 0.0])
        @is_flee = args > 0.01
      end

      if @is_return
        args = (ORIGIN_POINT - @position).r
        @position += Vector[0, 0, Math.sin(args) * 0.1]
        if args < 0.01
          @is_return = false
          @position = ORIGIN_POINT
        end
        @view = Drawing::Matrix.look_at(@position, Vector[0.0, 0.0, 10.0], Vector[0.0, 1.0, 0.0])
      end
    end

  end
end
