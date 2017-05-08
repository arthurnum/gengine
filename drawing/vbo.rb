module Drawing
  class VBO
    TARGETS = {
      vertex: GL_ARRAY_BUFFER,
      index: GL_ELEMENT_ARRAY_BUFFER
    }

    def initialize(target)
      id_buf = '    ' # 4 bytes for buffer ID
      glGenBuffers(1, id_buf)
      @id = id_buf.unpack('L')[0]
      @target = TARGETS[target]
    end

    def bind
      glBindBuffer(@target, @id)
    end

    def data(data)
      glBufferData(@target, data.size, data.pack, GL_STATIC_DRAW)
    end

    def sub_data(data, offset = 0)
      glBufferSubData(@target, offset, data.size, data.pack)
    end
  end
end
