require 'opengl'

module GLSL
  class Program
    include Gl

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
  end
end
