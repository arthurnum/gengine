module GLSL
  class Shader
    TYPES = { vertex: GL_VERTEX_SHADER,
              fragment: GL_FRAGMENT_SHADER }

    attr_reader :id

    def initialize(type, source)
      @id = glCreateShader(TYPES[type])
      glShaderSource(@id, source)
      glCompileShader(@id)
    end
  end
end
