module GLSL
  class Program
    def initialize
      @id = glCreateProgram
      @uniform_locations = {}
    end

    def attach_shader(shader)
      glAttachShader(@id, shader.id)
    end

    def attach_shaders(*shaders)
      shaders.each { |s| attach_shader(s) }
    end

    def link
      glLinkProgram(@id)
    end

    def use
      glUseProgram(@id)
    end

    def link_and_use
      link; use
    end

    def uniform_matrix4(matrix, name, count = 1)
      ul = get_uniform_location(name)
      if matrix.is_a? Array
        value = ""
        matrix.each { |matx| value += matx.data }
        glUniformMatrix4fv(ul, count, GL_TRUE, value)
      else
        glUniformMatrix4fv(ul, count, GL_TRUE, matrix.to_a.flatten.pack('F*'))
      end
    end

    def uniform_vector(vector, name)
      ul = get_uniform_location(name)
      glUniform3fv(ul, 1, vector.to_a.pack('F*'))
    end

    def uniform_vector2fv(vector, name)
      ul = get_uniform_location(name)
      glUniform2fv(ul, 1, vector.to_a.pack('F*'))
    end

    def uniform_vector4fv(vector, name)
      ul = get_uniform_location(name)
      glUniform4fv(ul, 1, vector.to_a.pack('F*'))
    end

    def uniform_1i(name, value)
      ul = get_uniform_location(name)
      glUniform1i(ul, value)
    end

    def get_attrib_location(name)
      glGetAttribLocation(@id, name)
    end

    private

    def get_uniform_location(name)
      @uniform_locations[name] ||= glGetUniformLocation(@id, name)
    end
  end
end
