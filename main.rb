require 'sdl2'
require 'opengl'

require 'pry'

require_relative 'glsl/program.rb'
require_relative 'glsl/shader.rb'

include Gl
include GLSL

vertex_shader_code = %q(
    #version 330
    layout(location=0) in vec2 position;
    void main()
    {
      gl_Position = vec4(position, 0, 0);
    }
  )

fragment_shader_code = %q(
    #version 330
    out vec4 out_color;
    void main()
    {
      out_color = vec4(1, 1, 1, 0);
    }
  )


def render
  glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)
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