module GLSL
  class Shader
    TYPES = { vertex: GL_VERTEX_SHADER,
              fragment: GL_FRAGMENT_SHADER }

    attr_reader :id

    def initialize(type, source)
      @id = glCreateShader(TYPES[type])
      glShaderSource(@id, 1, [source].pack('p'), [source.size].pack('I'))
      glCompileShader(@id)
    end
  end
end
