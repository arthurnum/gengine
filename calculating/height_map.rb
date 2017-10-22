module Calculating
  class HeightMap
    attr_reader :height_data

    def initialize(data)
      @height_data = data
    end

    def get_y_by(x, z)
      # j_off = (255 * (1.0 - @position[2] / 350.0)).round * 256
      j_off = 255 * (1.0 - z / 350.0)
      j_off0 = j_off.floor
      j_off1 = j_off.ceil
      i_off = 255 * (x / 350.0)
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
    end

  end
end
