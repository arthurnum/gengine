module Drawing
  class Camera
    attr_reader :position, :look_at
    attr_accessor :height_data

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
      angle_rad = @angle.to_rad
      cosv = Math.cos(angle_rad)
      sinv = Math.sin(angle_rad)
      @position += Vector[-aspect * sinv, 0.0, -aspect * cosv]

      yh = height_data.get_y_by(@position[0], @position[2])
      @position = Vector[@position[0], yh, @position[2]]

      calculate_look_at
    end

    def move_y(aspect)
      @position += Vector[0.0, aspect, 0.0]
      calculate_look_at
    end

    def normal
      (@position - @look_at).normalize
    end

    private

    def calculate_look_at
      angle_rad = @angle.to_rad
      cosv = Math.cos(angle_rad)
      sinv = Math.sin(angle_rad)
      look_at_x = @position[0] + 10.0 * sinv
      look_at_y = @position[1] - 1.0
      look_at_z = @position[2] + 10.0 * cosv
      @look_at = Vector[look_at_x, look_at_y, look_at_z]
    end
  end
end
