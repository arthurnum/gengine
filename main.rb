require 'sdl2'
require 'opengl'

require 'pry'

OpenGL.load_lib
include OpenGL

require_relative 'glsl/glsl'
require_relative 'drawing/drawing'
require_relative 'calculating/calculating'
require_relative 'context/context'
require_relative 'network/socket'

include GLSL

@world = Drawing::World.new

touch_supervbo = false

def render
  glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)

  glActiveTexture(GL_TEXTURE0)
  @texture1.bind
  glActiveTexture(GL_TEXTURE1)
  @texture2.bind
  @program.use
  @program.uniform_1i("texture1", 0)
  @program.uniform_1i("texture2", 1)
  @program.uniform_matrix4(@world.matrix.world, 'MVP')
  @landscape.draw

  @program_cube.use
  cube_matrix = @world.matrix.world.translate(@cube.x, @cube.y, @cube.z)
  @program_cube.uniform_matrix4(cube_matrix, 'MVP')
  @cube.draw

  @program_ortho2d.use
  @program_ortho2d.uniform_matrix4(@mart, 'MVP')

  glActiveTexture(GL_TEXTURE0)
  @texture1.bind
  @program_ortho2d.uniform_1i("texture1", 0)
  @rect.draw

  glActiveTexture(GL_TEXTURE0)
  @texture2.bind
  @program_ortho2d.uniform_1i("texture1", 0)
  @rect2.draw
end

SDL2.init(SDL2::INIT_EVERYTHING)
SDL2::GL.set_attribute(SDL2::GL::DOUBLEBUFFER, 1)
SDL2::GL.set_attribute(SDL2::GL::CONTEXT_MAJOR_VERSION, 3)
SDL2::GL.set_attribute(SDL2::GL::CONTEXT_MINOR_VERSION, 3)
SDL2::GL.set_attribute(SDL2::GL::CONTEXT_PROFILE_MASK, SDL2::GL::CONTEXT_PROFILE_CORE)

# You need to create a window with `OPENGL' flag
window = Context::Window.new(1920.0, 1080.0)

# Create a OpenGL context attached to the window
context = SDL2::GL::Context.create(window.sdl_window)

glViewport(0, 0, window.width, window.height)
glClearColor(0,0,0,0)
glEnable(GL_DEPTH_TEST)

vertex_shader = Shader.new(:vertex, Collection::VERTEX_SHADER_S3)
fragment_shader = Shader.new(:fragment, Collection::FRAGMENT_SHADER_S3)
vertex_cube_shader = Shader.new(:vertex, Collection::VERTEX_SHADER_CUBE)
fragment_cube_shader = Shader.new(:fragment, Collection::FRAGMENT_SHADER_CUBE)
vertex_ortho2d_shader = Shader.new(:vertex, Collection::VERTEX_SHADER_ORTHO2D)
fragment_ortho2d_shader = Shader.new(:fragment, Collection::FRAGMENT_SHADER_ORTHO2D)

@program = Program.new
@program.attach_shaders(vertex_shader, fragment_shader)
@program.link_and_use

@program_cube = Program.new
@program_cube.attach_shaders(vertex_cube_shader, fragment_cube_shader)
@program_cube.link

@program_ortho2d = Program.new
@program_ortho2d.attach_shaders(vertex_ortho2d_shader, fragment_ortho2d_shader)
@program_ortho2d.link

@world.camera = Drawing::Camera.new(Vector[0.0, 3.0, -10.0], 0.0)
@world.matrix.projection = Drawing::Matrix.perspective(65, window.width, window.height, 0.1, 1000.0)
@world.matrix.view = @world.camera.view
@world.matrix.model = Drawing::Matrix.identity(4)

@program.uniform_matrix4(@world.matrix.world, 'MVP')
@program.uniform_vector2fv(Vector[0.0, 0.0], 'texture_center')


  glActiveTexture(GL_TEXTURE0)
  @texture1 = Drawing::Texture.new
  @texture1.bind
  @texture1.load("./textures/ccw.bmp")

  @program.uniform_1i("texture1", 0)

  glActiveTexture(GL_TEXTURE1)
  @texture2 = Drawing::Texture.new
  @texture2.bind
  @texture2.load("./textures/mf.bmp")

  @program.uniform_1i("texture2", 1)

  @landscape = Drawing::Object::Landscape.new(50)
  @rect = Drawing::Object::Rectangle.new(10.0, 10.0, 100.0, 100.0)
  @rect2 = Drawing::Object::Rectangle.new(10.0, 120.0, 100.0, 100.0)
  @cube = Drawing::Object::Cube.new(0.0, 0.0, 0.0, 0.5)
  @cube.position = Vector[0.0, 2.0, 4.0]
  @mart = Drawing::Matrix.ortho2d(0.0, window.width, 0.0, window.height)

  puts "Landscape size: #{@landscape.size}"

focus_array = []

time_a = Time.now
frames = 0.0

Context::WindowCallbacks.init(window)
constructor = Context::Constructor.new(window, @world)

h_edit_face = lambda do |win, ev|
  if ev.scancode == SDL2::Key::Scan::UP
    @landscape.up!(constructor.shift_radius)
    touch_supervbo = true
  end

  if ev.scancode == SDL2::Key::Scan::DOWN
    @landscape.down!(constructor.shift_radius)
    touch_supervbo = true
  end
end

h_apply_texture = lambda do |win, ev|
  if ev.scancode == SDL2::Key::Scan::LEFT
    @landscape.focus_array.each do |face|
      face.each_vertex do |v|
        v.uva -= 0.1
        v.uva = 0.0 if v.uva < 0.0
      end
    end

    @landscape.update_uvavbo
  end

  if ev.scancode == SDL2::Key::Scan::RIGHT
    @landscape.focus_array.each do |face|
      face.each_vertex do |v|
        v.uva += 0.1
        v.uva = 1.0 if v.uva > 1.0
      end
    end

    @landscape.update_uvavbo
  end
end

h_mouse_down = lambda do |win, ev|
  ray = Calculating::Ray.new
  ray.trace(@world.matrix.world, window.width, window.height, ev.x, window.height - ev.y)
  @landscape.ray_intersect(ray)

  @landscape.update_colorvbo
end

window.register_event_handler(:key_down, h_edit_face)
window.register_event_handler(:key_down, h_apply_texture)
window.register_event_handler(:mouse_button_down, h_mouse_down)

network = Network::Client.new(ARGV[0], @cube)
network.write

# You can use OpenGL functions
loop do
  network.read

  render

  window.events_poll
  exit if window.exit?

  window.gl_swap

  if touch_supervbo
    @landscape.update_supervbo
    touch_supervbo = false
  end

  network.write

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
