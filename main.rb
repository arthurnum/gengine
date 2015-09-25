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
    layout(location=0) in vec3 pos;
    uniform mat4 MVP;
    void main()
    {
      gl_Position = MVP * vec4(pos.x, pos.y, pos.z, 1.0);
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

  data = [-1.0, -1.0, -3.0,
          -1.0,  1.0, -3.0,
           1.0, -1.0, -3.0,
           1.0,  1.0, -3.0,
           1.0, -1.0, -5.0,
           1.0,  1.0, -5.0
         ]
  inds = [0, 1, 2, 3, 4, 5]

  vertices = Drawing::Data::Float.new(data)
  vbo = Drawing::VBO.new(:vertex)
  vbo.bind
  vbo.data(vertices)
  glEnableVertexAttribArray(0)
  glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 0, 0)

  indices = Drawing::Data::UInt.new(inds)
  vbo2 = Drawing::VBO.new(:index)
  vbo2.bind
  vbo2.data(indices)

  glPolygonMode(GL_FRONT_AND_BACK, GL_LINE)
  glDrawElements(GL_TRIANGLE_STRIP, 6, GL_UNSIGNED_INT, 0);
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
# glEnable(GL_DEPTH_TEST)

vertex_shader = Shader.new(:vertex, vertex_shader_code)
fragment_shader = Shader.new(:fragment, fragment_shader_code)

program = Program.new
program.attach_shaders(vertex_shader, fragment_shader)
program.link_and_use

projection_matrix = Drawing::Matrix.perspective(55.0, 1024.0, 768.0, 0.1, 10.0)
view_matrix = Drawing::Matrix.look_at(Vector[2.0, 5.0, 2.0], Vector[0.0, 0.0, -4.0], Vector[0.0, 1.0, 0.0])
model_matrix = Drawing::Matrix.identity(4)

mvp_matrix = projection_matrix * view_matrix * model_matrix
program.uniform_matrix4(mvp_matrix, 'MVP')

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
