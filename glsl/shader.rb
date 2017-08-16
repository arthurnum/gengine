module GLSL
  class Shader
    TYPES = { vertex: GL_VERTEX_SHADER,
              fragment: GL_FRAGMENT_SHADER }

    attr_reader :id

    def initialize(type, source)
      @id = glCreateShader(TYPES[type])
      glShaderSource(@id, 1, [source].pack('p'), [source.size].pack('I'))
      glCompileShader(@id)

      if complile_error?
        puts "Shader error."
        puts error_log
      end
    end

    def complile_error?
      buf = '    '
      glGetShaderiv(@id, GL_COMPILE_STATUS, buf)
      buf.unpack('L')[0] == 0
    end

    def error_log
      buf = '    '
      glGetShaderiv(@id, GL_INFO_LOG_LENGTH, buf)
      info_log_length = buf.unpack('L')[0]
      buf = "%#{info_log_length}s" % " "
      glGetShaderInfoLog(@id, 100, nil, buf)
      buf
    end
  end
end
