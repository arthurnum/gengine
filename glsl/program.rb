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
      glUniformMatrix4fv(ul, 1, GL_TRUE, matrix.to_a.flatten.pack('F*'));
    end

    private

    def get_uniform_location(name)
      glGetUniformLocation(@id, name)
    end
  end
end
