module Drawing
  class Texture
    def initialize
      id_array = '    ' # 4 bytes for array ID
      glGenTextures(1, id_array)
      @id = id_array.unpack('L')[0]
    end

    def bind
      glBindTexture(GL_TEXTURE_2D, @id)
    end

    def load(path)
      image = SDL2::Surface.load_bmp(path)

      create_or_update(image.pixels)

      glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, image.w, image.h, 0, GL_BGR, GL_UNSIGNED_BYTE, 0)
      glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR)
      glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR)

      image.pixels
    end

    def print(font, string)
      surface = font.render_solid(string, [1,1,1])

      create_or_update(surface.pixels)

      glTexImage2D(GL_TEXTURE_2D, 0, GL_R3_G3_B2, surface.w, surface.h, 0, GL_RGB, GL_UNSIGNED_BYTE_3_3_2, 0)
      glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR)
      glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR)

      [surface.w, surface.h]
    end

    private

    def create_or_update(pixels)
      @pbo ? update_pbo(pixels) : create_pbo(pixels)
    end

    def create_pbo(pixels)
      @pbo = Drawing::PBO.new
      @pbo.bind
      @pbo.data(pixels)
    end

    def update_pbo(pixels)
      @pbo.bind
      # updated pixels data comes with variable size
      # need to generate new buffer
      @pbo.data(pixels)
      # @pbo.sub_data(pixels)
    end
  end
end
