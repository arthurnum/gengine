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

      pbo = Drawing::PBO.new
      pbo.bind
      pbo.data(image.pixels)

      glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, image.w, image.h, 0, GL_BGR, GL_UNSIGNED_BYTE, 0)
      glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR)
      glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR)

      image.pixels
    end
  end
end
