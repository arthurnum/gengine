module Drawing
  class Camera
    attr_reader :position, :look_at

    def initialize(position, angle)
      @position = position
      @angle = angle
      calculate_look_at
    end

    def view
      Drawing::Matrix.look_at(position, look_at, Vector[0.0, 1.0, 0.0])
    end

    def rotate(degrees)
      @angle += degrees
      @angle = 360 + degrees if @angle < 0
      @angle = degrees if @angle > 360
      calculate_look_at
    end

    def move(aspect)
      angle_rad = @angle * Math::PI / 180.0
      cosv = Math.cos(angle_rad)
      sinv = Math.sin(angle_rad)
      @position += Vector[-aspect * sinv, 0.0, -aspect * cosv]
      calculate_look_at
    end

    def move_y(aspect)
      @position += Vector[0.0, aspect, 0.0]
      calculate_look_at
    end

    private

    def calculate_look_at
      angle_rad = @angle * Math::PI / 180.0
      cosv = Math.cos(angle_rad)
      sinv = Math.sin(angle_rad)
      look_at_x = @position[0] + 10.0 * sinv
      look_at_z = @position[2] + 10.0 * cosv
      @look_at = Vector[look_at_x, 0.0, look_at_z]
    end
  end
end
