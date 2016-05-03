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

    def load_bmp(path)
      image = SDL2::Surface.load_bmp(path)
      glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, image.w, image.h, 0, GL_BGR, GL_UNSIGNED_BYTE, image.pixels)
      glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR)
      glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR)
    end

    def setup(image)
      glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, image.w, image.h, 0, GL_BGR, GL_UNSIGNED_BYTE, 0)
      glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR)
      glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR)
    end
  end
end
