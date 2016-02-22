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
@world.matrix.view = Drawing::Matrix.look_at(Vector[0.0, 15.0, -2.0], Vector[0.0, 0.0, 50.0], Vector[0.0, 1.0, 0.0])
@world.matrix.model = Drawing::Matrix.identity(4)

@program.uniform_matrix4(@world.matrix.world, 'MVP')

  texture = Drawing::Texture.new
  texture.bind
  texture.load_bmp("./textures/mf.bmp")
  @program.uniform_1i("texture1", 0)
  glActiveTexture(0)
  texture.bind

  landscape = Drawing::Object::Landscape.new(50)

  vao = Drawing::VAO.new
  vao.bind

  supervbo = Drawing::VBO.new(:vertex)
  supervbo.bind
  supervbo.data(landscape.vn_data)
  vao.set_array_pointer(0, 3, GL_FLOAT, GL_FALSE, 24, 0)
  vao.set_array_pointer(1, 3, GL_FLOAT, GL_FALSE, 24, 12)

  vbo = Drawing::VBO.new(:vertex)
  vbo.bind
  vbo.data(landscape.colors_data)
  vao.set_array_pointer(2, 3, GL_FLOAT, GL_FALSE, 0, 0)

  vbo2 = Drawing::VBO.new(:index)
  vbo2.bind
  vbo2.data(landscape.indices_data)

  @count = landscape.size

model_mode = false

focus_array = []

time_a = Time.now
frames = 0.0

h_escape = lambda do |win, ev|
  win.exit if ev.scancode == SDL2::Key::Scan::ESCAPE
end

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
  end

  supervbo.bind
  supervbo.data(landscape.vn_data)
end

h_resized = lambda do |win, ev|
  p 'Augh! RESIZED!'
end

h_mouse_down = lambda do |win, ev|
  ray = Calculating::Ray.new
  ray.trace(@world.matrix.world, window.width, window.height, ev.x, window.height - ev.y)
  focus_array = ray.intersection(landscape.faces)
  vbo = Drawing::VBO.new(:vertex)
  vbo.bind
  vbo.data(landscape.colors_data)
  vao.set_array_pointer(2, 3, GL_FLOAT, GL_FALSE, 0, 0)
end

h_mouse_up = lambda do |win, ev|
  if ev.clicks > 1
    model_mode = !model_mode
    p "Model mode #{model_mode ? 'ON' : 'OFF'}"
  end
end

h_mouse_motion = lambda do |win, ev|
  @world.matrix.view = @world.matrix.view.translate(ev.xrel*0.01, -ev.yrel*0.01, 0.0) if model_mode
end

h_mouse_wheel = lambda do |win, ev|
  @world.matrix.view = @world.matrix.view.translate(0.0, 0.0, -ev.y*0.1) if model_mode
end

window.register_event_handler(:key_down, h_escape)
window.register_event_handler(:key_down, h_edit_face)
window.register_event_handler(:window, h_resized)
window.register_event_handler(:mouse_button_down, h_mouse_down)
window.register_event_handler(:mouse_button_up, h_mouse_up)
window.register_event_handler(:mouse_motion, h_mouse_motion)
window.register_event_handler(:mouse_wheel, h_mouse_wheel)

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
