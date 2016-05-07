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

def render
  glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)

  @program.uniform_matrix4(@world.matrix.world, 'MVP')
  @program.uniform_matrix4(@world.matrix.model, 'M')
  @program.uniform_matrix4(@world.matrix.view, 'V')

  glDrawElements(GL_TRIANGLE_STRIP, @count, GL_UNSIGNED_INT, 0);
end

SDL2.init(SDL2::INIT_EVERYTHING)
SDL2::GL.set_attribute(SDL2::GL::DOUBLEBUFFER, 1)
SDL2::GL.set_attribute(SDL2::GL::CONTEXT_MAJOR_VERSION, 3)
SDL2::GL.set_attribute(SDL2::GL::CONTEXT_MINOR_VERSION, 3)
SDL2::GL.set_attribute(SDL2::GL::CONTEXT_PROFILE_MASK, SDL2::GL::CONTEXT_PROFILE_CORE)

# You need to create a window with `OPENGL' flag
window = Context::Window.new(1024.0, 768.0)

# Create a OpenGL context attached to the window
context = SDL2::GL::Context.create(window.sdl_window)

glViewport(0, 0, window.width, window.height)
glClearColor(0,0,0,0)
glEnable(GL_DEPTH_TEST)

vertex_shader = Shader.new(:vertex, Collection::VERTEX_SHADER_S3)
fragment_shader = Shader.new(:fragment, Collection::FRAGMENT_SHADER_S3)

@program = Program.new
@program.attach_shaders(vertex_shader, fragment_shader)
@program.link_and_use

@world.matrix.projection = Drawing::Matrix.perspective(65, window.width, window.height, 0.1, 1000.0)
@world.matrix.view = Drawing::Matrix.look_at(Vector[0.0, 20.0, -20.0], Vector[0.0, 0.0, 50.0], Vector[0.0, 1.0, 0.0])
@world.matrix.model = Drawing::Matrix.identity(4)

@program.uniform_matrix4(@world.matrix.world, 'MVP')
@program.uniform_vector2fv(Vector[0.0, 0.0], 'texture_center')


  glActiveTexture(GL_TEXTURE0)
  texture1 = Drawing::Texture.new
  texture1.bind
  texture1.load("./textures/ccw.bmp")

  @program.uniform_1i("texture1", 0)

  glActiveTexture(GL_TEXTURE1)
  texture2 = Drawing::Texture.new
  texture2.bind
  texture2.load("./textures/mf.bmp")

  @program.uniform_1i("texture2", 1)

  landscape = Drawing::Object::Landscape.new(50)

  vao = Drawing::VAO.new
  vao.bind

  supervbo = Drawing::VBO.new(:vertex)
  supervbo.bind
  supervbo.data(landscape.vn_data)
  vao.set_array_pointer(0, 3, GL_FLOAT, GL_FALSE, 24, 0)
  vao.set_array_pointer(1, 3, GL_FLOAT, GL_FALSE, 24, 12)


  uva_vbo = Drawing::VBO.new(:vertex)
  uva_vbo.bind
  uva_vbo.data(landscape.uva_data)
  vao.set_array_pointer(2, 1, GL_FLOAT, GL_FALSE, 0, 0)

  vbo = Drawing::VBO.new(:vertex)
  vbo.bind
  vbo.data(landscape.colors_data)
  vao.set_array_pointer(3, 3, GL_FLOAT, GL_FALSE, 0, 0)

  vbo2 = Drawing::VBO.new(:index)
  vbo2.bind
  vbo2.data(landscape.indices_data)

  @count = landscape.size

focus_array = []

time_a = Time.now
frames = 0.0

Context::WindowCallbacks.init(window)
constructor = Context::Constructor.new(window, @world)

h_edit_face = lambda do |win, ev|
  if ev.scancode == SDL2::Key::Scan::UP
    focus_array.each do |face|
      center = face.v1
      landscape.vertices.each do |vert|
        dt = Math.sqrt( (vert.x - center.x)**2 + (vert.z - center.z)**2 )
        shift = 0.05 * ( (20.0 - dt) / 20.0 )
        if shift > 0.0
          vert.vector += Vector[0.0, shift, 0.0]
          vert.faces.each { |f| f.reset_normal }
        end
      end
    end

    supervbo.bind
    supervbo.data(landscape.vn_data)
  end

  if ev.scancode == SDL2::Key::Scan::DOWN
    focus_array.each do |face|
      center = face.v1
      landscape.vertices.each do |vert|
        dt = Math.sqrt( (vert.x - center.x)**2 + (vert.z - center.z)**2 )
        shift = 0.05 * ( (20.0 - dt) / 20.0 )
        if shift > 0.0
          vert.vector += Vector[0.0, -shift, 0.0]
          vert.faces.each { |f| f.reset_normal }
        end
      end
    end

    supervbo.bind
    supervbo.data(landscape.vn_data)
  end
end

h_apply_texture = lambda do |win, ev|
  if ev.scancode == SDL2::Key::Scan::LEFT
    focus_array.each do |face|
      face.each_vertex do |v|
        v.uva -= 0.1
        v.uva = 0.0 if v.uva < 0.0
      end
    end

    uva_vbo.bind
    uva_vbo.data(landscape.uva_data)
  end

  if ev.scancode == SDL2::Key::Scan::RIGHT
    focus_array.each do |face|
      face.each_vertex do |v|
        v.uva += 0.1
        v.uva = 1.0 if v.uva > 1.0
      end
    end

    uva_vbo.bind
    uva_vbo.data(landscape.uva_data)
  end
end

h_mouse_down = lambda do |win, ev|
  ray = Calculating::Ray.new
  ray.trace(@world.matrix.world, window.width, window.height, ev.x, window.height - ev.y)
  focus_array = ray.intersection(landscape.faces)
  vbo = Drawing::VBO.new(:vertex)
  vbo.bind
  vbo.data(landscape.colors_data)
  vao.set_array_pointer(3, 3, GL_FLOAT, GL_FALSE, 0, 0)
end

window.register_event_handler(:key_down, h_edit_face)
window.register_event_handler(:key_down, h_apply_texture)
window.register_event_handler(:mouse_button_down, h_mouse_down)

# You can use OpenGL functions
loop do
  render

  window.events_poll
  exit if window.exit?

  window.gl_swap

  frames += 1.0
  time_b = Time.now
  delta = time_b - time_a
  if delta > 2.0
    p "FPS #{frames / delta}"
    time_a = time_b
    frames = 0
  end
end

# Delete the context after using OpenGL functions
context.destroy
