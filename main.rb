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
  @texture4.bind
  glActiveTexture(GL_TEXTURE1)
  @texture5.bind
  glActiveTexture(GL_TEXTURE2)
  @texture1.bind
  glActiveTexture(GL_TEXTURE3)
  @texture2.bind
  @program4.use
  @program4.uniform_1i("texture1", 0)
  @program4.uniform_1i("texture2", 1)
  @program4.uniform_1i("texture3", 2)
  @program4.uniform_1i("texture4", 3)
  @program4.uniform_matrix4(@world.matrix.world, 'MVP')
  model_view = @world.matrix.model * @world.matrix.view
  normal_view = model_view.inverse.transpose
  @program4.uniform_matrix4(model_view, 'ModelView')
  @program4.uniform_matrix4(normal_view, 'NormalView')
  @landscape4.draw

  @program_cube.use
  @cubes.each do |k, cube|
    cube_matrix = @world.matrix.world.translate(cube.x, cube.y, cube.z)
    @program_cube.uniform_matrix4(cube_matrix, 'MVP')
    cube.draw
  end

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

  @program_ortho2d_info.use
  @program_ortho2d_info.uniform_matrix4(@mart, 'MVP')
  glEnable(GL_BLEND)
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
  glActiveTexture(GL_TEXTURE0)
  @texture_font.bind
  @program_ortho2d.uniform_1i("texture1", 0)
  @rect_font.draw
  glDisable(GL_BLEND)
end

SDL2.init(SDL2::INIT_EVERYTHING)
SDL2::TTF.init
SDL2::GL.set_attribute(SDL2::GL::DOUBLEBUFFER, 1)
SDL2::GL.set_attribute(SDL2::GL::CONTEXT_MAJOR_VERSION, 3)
SDL2::GL.set_attribute(SDL2::GL::CONTEXT_MINOR_VERSION, 3)
SDL2::GL.set_attribute(SDL2::GL::CONTEXT_PROFILE_MASK, SDL2::GL::CONTEXT_PROFILE_CORE)

# You need to create a window with `OPENGL' flag
window = Context::Window.new(600.0, 480.0)

# Create a OpenGL context attached to the window
context = SDL2::GL::Context.create(window.sdl_window)

glViewport(0, 0, window.width, window.height)
glClearColor(0,0,0,0)
glEnable(GL_DEPTH_TEST)

vertex_shader = Shader.new(:vertex, Collection::VERTEX_SHADER_S3)
fragment_shader = Shader.new(:fragment, Collection::FRAGMENT_SHADER_S3)
vertex_shader4 = Shader.new(:vertex, Collection::VERTEX_SHADER_S4)
fragment_shader4 = Shader.new(:fragment, Collection::FRAGMENT_SHADER_S4)
vertex_cube_shader = Shader.new(:vertex, Collection::VERTEX_SHADER_CUBE)
fragment_cube_shader = Shader.new(:fragment, Collection::FRAGMENT_SHADER_CUBE)
vertex_ortho2d_shader = Shader.new(:vertex, Collection::VERTEX_SHADER_ORTHO2D)
fragment_ortho2d_shader = Shader.new(:fragment, Collection::FRAGMENT_SHADER_ORTHO2D)
fragment_ortho2d_shader_blend_info = Shader.new(:fragment, Collection::FRAGMENT_SHADER_ORTHO2D_BLEND_INFO)

@program4 = Program.new
@program4.attach_shaders(vertex_shader4, fragment_shader4)
@program4.link

@program_cube = Program.new
@program_cube.attach_shaders(vertex_cube_shader, fragment_cube_shader)
@program_cube.link

@program_ortho2d = Program.new
@program_ortho2d.attach_shaders(vertex_ortho2d_shader, fragment_ortho2d_shader)
@program_ortho2d.link

@program_ortho2d_info = Program.new
@program_ortho2d_info.attach_shaders(vertex_ortho2d_shader, fragment_ortho2d_shader_blend_info)
@program_ortho2d_info.link

# @world.camera = Drawing::Camera.new(Vector[0.0, 3.0, -10.0], 0.0)
@world.camera = Drawing::Camera.new(Vector[0.0, 0.0, 0.0], 0.0)
@world.matrix.projection = Drawing::Matrix.perspective(65, window.width, window.height, 0.1, 1000.0)
@world.matrix.view = @world.camera.view
@world.matrix.model = Drawing::Matrix.identity(4)

  @texture1 = Drawing::Texture.new
  @texture1.bind
  @texture1.load("./textures/pgrass.bmp")

  @texture2 = Drawing::Texture.new
  @texture2.bind
  @texture2.load("./textures/mf.bmp")

  @texture4 = Drawing::Texture.new
  @texture4.bind
  @rawh = @texture4.load("./textures/Rivwide.bmp")
  @rawh = @rawh.unpack "C*"
  @world.camera.height_data = 0.step(@rawh.size - 1, 3).map { |i| @rawh[i] }

  @texture5 = Drawing::Texture.new
  @texture5.bind
  @texture5.load("./textures/normalm.bmp")
  
  font = SDL2::TTF.open('EUROCAPS.TTF', 18, 0)
  @texture_font = Drawing::Texture.new
  @texture_font.bind
  sw, sh = @texture_font.print(font, "FPS: 0.0")

  @landscape = Drawing::Object::Landscape.new(10)
  @landscape4 = Drawing::Object::Landscape2.new(350)
  @rect = Drawing::Object::Rectangle.new(10.0, 10.0, 100.0, 100.0)
  @rect2 = Drawing::Object::Rectangle.new(10.0, 120.0, 100.0, 100.0)
  @rect_font = Drawing::Object::Rectangle.new(10.0, 400.0, sw, sh)
  @mart = Drawing::Matrix.ortho2d(0.0, window.width, 0.0, window.height)
  @cubes = {}

  # puts "Landscape size: #{@landscape.size}"

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

network = Network::Client.new(ARGV[0] || '127.0.0.1', @cubes)
pp = Network::Protocol::PacketCamera.new
pp.vector = @world.camera.position.to_a
network.write [pp]

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

  pp.vector = @world.camera.position.to_a
  network.write [pp]

  frames += 1.0
  time_b = Time.now
  delta = time_b - time_a
  if delta > 2.0
    p "FPS #{frames / delta}"

    @texture_font.bind
    sw, sh = @texture_font.print(font, "FPS: #{(frames / delta).round(2)}")
    @rect_font.update_vertices(10.0, 400.0, sw, sh)

    time_a = time_b
    frames = 0
  end
end

# Delete the context after using OpenGL functions
context.destroy
