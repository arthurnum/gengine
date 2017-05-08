module Drawing
  class PBO
    TARGET = GL_PIXEL_UNPACK_BUFFER

    def initialize
      id_buf = '    ' # 4 bytes for buffer ID
      glGenBuffers(1, id_buf)
      @id = id_buf.unpack('L')[0]
    end

    def bind
      glBindBuffer(TARGET, @id)
    end

    def data(pixels)
      glBufferData(TARGET, pixels.size, pixels, GL_STATIC_DRAW)
    end

    def sub_data(pixels, offset = 0)
      glBufferSubData(TARGET, offset, pixels.size, pixels)
    end
  end
end
