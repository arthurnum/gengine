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
      angle_rad = @angle * Math::PI / 180.0
      cosv = Math.cos(angle_rad)
      sinv = Math.sin(angle_rad)
      @position += Vector[-aspect * sinv, 0.0, -aspect * cosv]

      # j_off = (255 * (1.0 - @position[2] / 350.0)).round * 256
      j_off = 255 * (1.0 - @position[2] / 350.0)
      j_off0 = j_off.floor
      j_off1 = j_off.ceil
      i_off = 255 * (@position[0] / 350.0)
      i_off0 = i_off.floor
      i_off1 = i_off.ceil
      # i_off = (255 * (@position[0] / 350.0)).round
      y0 = height_data[j_off0 * 256 + i_off0] || 0
      y1 = height_data[j_off0 * 256 + i_off1] || 0
      # yh = (height_data[j_off + i_off] || 0) / 8.0 + 2.0
      if i_off0 - i_off1 == 0
        yh0 = y0 / 5 + 2.0
      else
        a = (y0 - y1) / (i_off0 - i_off1)
        b = y0 - a * i_off0
        yh0 = (a * i_off + b) / 5 + 2.0
      end

      y0 = height_data[j_off1 * 256 + i_off0] || 0
      y1 = height_data[j_off1 * 256 + i_off1] || 0
      if i_off0 - i_off1 == 0
        yh1 = y0 / 5 + 2.0
      else
        a = (y0 - y1) / (i_off0 - i_off1)
        b = y0 - a * i_off0
        yh1 = (a * i_off + b) / 5 + 2.0
      end

      a = (yh0 - yh1) / (j_off0 - j_off1)
      b = yh0 - a * j_off0
      yh = (a * j_off + b)
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
      angle_rad = @angle * Math::PI / 180.0
      cosv = Math.cos(angle_rad)
      sinv = Math.sin(angle_rad)
      look_at_x = @position[0] + 10.0 * sinv
      look_at_y = @position[1] - 1.0
      look_at_z = @position[2] + 10.0 * cosv
      @look_at = Vector[look_at_x, look_at_y, look_at_z]
    end
  end
end
