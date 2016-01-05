require 'sdl2'
require 'opengl'

require 'pry'

OpenGL.load_lib
include OpenGL

require_relative 'glsl/glsl'
require_relative 'drawing/drawing'
require_relative 'calculating/calculating'
require_relative 'context/context'

include GLSL

@world = Drawing::World.new

SDL2.init(SDL2::INIT_EVERYTHING)
SDL2::GL.set_attribute(SDL2::GL::DOUBLEBUFFER, 1)
SDL2::GL.set_attribute(SDL2::GL::CONTEXT_MAJOR_VERSION, 3)
SDL2::GL.set_attribute(SDL2::GL::CONTEXT_MINOR_VERSION, 3)
SDL2::GL.set_attribute(SDL2::GL::CONTEXT_PROFILE_MASK, SDL2::GL::CONTEXT_PROFILE_CORE)


# You need to create a window with `OPENGL' flag
@window = Context::Window.new(1024.0, 768.0, false)


# vertex_shader = Shader.new(:vertex, Collection::VERTEX_SHADER_S1)
# fragment_shader = Shader.new(:fragment, Collection::FRAGMENT_SHADER_S1)
@vertex_shader = Shader.new(:vertex, Collection::VERTEX_SHADER_S2)
@fragment_shader = Shader.new(:fragment, Collection::FRAGMENT_SHADER_S2)

@program = Program.new
@program.attach_shaders(@vertex_shader, @fragment_shader)
@program.link_and_use

@world.matrix.projection = Drawing::Matrix.perspective(65, @window.width, @window.height, 0.1, 10.0)
@world.matrix.view = Drawing::Matrix.look_at(Vector[0.0, 5.5, -1.0], Vector[0.0, 0.0, 2.0], Vector[0.0, 1.0, 0.0])
@world.matrix.model = Drawing::Matrix.identity(4)

@program.uniform_matrix4(@world.matrix.world, 'MVP')

  @landscape = Drawing::Object::Landscape.new(50)

  @vao = Drawing::VAO.new
  @vao.bind

  @vbo = Drawing::VBO.new(:vertex)
  @vbo.bind
  @vbo.data(@landscape.vertices_data)
  @vao.set_array_pointer(0, 3, GL_FLOAT, GL_FALSE, 0, 0)

  @vbo = Drawing::VBO.new(:vertex)
  @vbo.bind
  @vbo.data(@landscape.normals_data)
  @vao.set_array_pointer(1, 3, GL_FLOAT, GL_FALSE, 0, 0)

  @vbo = Drawing::VBO.new(:vertex)
  @vbo.bind
  @vbo.data(@landscape.colors_data)
  @vao.set_array_pointer(2, 3, GL_FLOAT, GL_FALSE, 0, 0)

  @vbo2 = Drawing::VBO.new(:index)
  @vbo2.bind
  @vbo2.data(@landscape.indices_data)

  @count = @landscape.size


@h_mouse_down = lambda do |x, y|
  ray = Calculating::Ray.new
  ray.trace(@world.matrix.world, @window.width, @window.height, x, @window.height - y)
  ray.intersection(@landscape.faces)
  # @program.uniform_vector(ray.near, 'rayNear')
  # @program.uniform_vector(ray.far, 'rayFar')
  vbo = Drawing::VBO.new(:vertex)
  vbo.bind
  vbo.data(@landscape.colors_data)
  @vao.set_array_pointer(2, 3, GL_FLOAT, GL_FALSE, 0, 0)
end
