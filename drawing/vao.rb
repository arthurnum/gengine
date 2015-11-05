module Drawing
  class VAO
    def initialize
      id_array = '    ' # 4 bytes for array ID
      glGenVertexArrays(1, id_array)
      @id = id_array.unpack('L')[0]
    end

    def bind
      glBindVertexArray(@id)
    end

    def enable_vertex_attrib_array(id)
      glEnableVertexAttribArray(id)
    end

    def vertex_attrib_pointer(id, size, type, normalized, stride, pointer)
      glVertexAttribPointer(id, size, type, normalized, stride, pointer)
    end

    def set_array_pointer(id, size, type, normalized, stride, pointer)
      enable_vertex_attrib_array(id)

      vertex_attrib_pointer(id, size, type, normalized, stride, pointer)
    end
  end
end
