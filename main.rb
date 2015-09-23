require 'sdl2'
require 'opengl'

require 'pry'


OpenGL.load_lib
include OpenGL

require_relative 'glsl/glsl'
require_relative 'drawing/drawing'

include GLSL

vertex_shader_code = %q(
    #version 330
    layout(location=0) in vec2 pos;
    void main()
    {
      gl_Position = vec4(pos.x, pos.y, 0.0, 10.0);
    }
  )

fragment_shader_code = %q(
    #version 330
    out vec4 out_color;
    void main()
    {
      out_color = vec4(1.0, 1.0, 1.0, 1.0);
    }
  )


def render
  glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)

  vao = '    '
  glGenVertexArrays(1, vao)
  glBindVertexArray(vao.unpack('L')[0])

  posBuf = '    '
  glGenBuffers(1, posBuf)
  glBindBuffer(GL_ARRAY_BUFFER, posBuf.unpack('L')[0])
  data = [-1.0, -1.0,
          -1.0,  1.0,
           1.0, -1.0,
           1.0,  1.0]
  indices = [0, 1, 2, 3]

  glBufferData(GL_ARRAY_BUFFER, 4*8, data.pack('F*'), GL_STREAM_DRAW)
  glVertexAttribPointer(0, 2, GL_FLOAT, GL_FALSE, 0, 0)
  glEnableVertexAttribArray(0)

  ib = '    '
  glGenBuffers(1, ib)
  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ib.unpack('L')[0])
  glBufferData(GL_ELEMENT_ARRAY_BUFFER, 4*4, indices.pack('I*'), GL_STREAM_DRAW)

  glDrawElements(GL_TRIANGLE_STRIP, 4, GL_UNSIGNED_INT, 0);
end

SDL2.init(SDL2::INIT_EVERYTHING)
SDL2::GL.set_attribute(SDL2::GL::DOUBLEBUFFER, 1)
SDL2::GL.set_attribute(SDL2::GL::CONTEXT_MAJOR_VERSION, 3)
SDL2::GL.set_attribute(SDL2::GL::CONTEXT_MINOR_VERSION, 3)
SDL2::GL.set_attribute(SDL2::GL::CONTEXT_PROFILE_MASK, SDL2::GL::CONTEXT_PROFILE_CORE)


# You need to create a window with `OPENGL' flag
window = SDL2::Window.create('GENGINE', 0, 0, 1024, 768,
                             (SDL2::Window::Flags::OPENGL | SDL2::Window::Flags::RESIZABLE))


# Create a OpenGL context attached to the window
context = SDL2::GL::Context.create(window)

glViewport(0, 0, 1024, 768)
glClearColor(0,0,0,0)

vertex_shader = Shader.new(:vertex, vertex_shader_code)

fragment_shader = Shader.new(:fragment, fragment_shader_code)

program = Program.new
program.attach_shaders(vertex_shader, fragment_shader)
program.link_and_use

# You can use OpenGL functions
loop do
  while ev = SDL2::Event.poll
    if SDL2::Event::KeyDown === ev && ev.scancode == SDL2::Key::Scan::ESCAPE
      exit
    end
    if SDL2::Event::Window === ev && ev.event == SDL2::Event::Window::RESIZED
      p 'Augh! RESIZED!'
    end
  end
  render
  window.gl_swap
  sleep 0.1
end

# Delete the context after using OpenGL functions
context.destroy
