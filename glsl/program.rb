module GLSL
  class Program
    def initialize
      @id = glCreateProgram
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

    def uniform_matrix4(matrix, name)
      ul = get_uniform_location(name)
      glUniformMatrix4fv(ul, 1, GL_TRUE, matrix.to_a.flatten.pack('F*'))
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

    private

    def get_uniform_location(name)
      glGetUniformLocation(@id, name)
    end
  end
end
