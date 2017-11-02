require_relative 'glsl/glsl'
require_relative 'drawing/drawing'
require_relative 'calculating/calculating'
require_relative 'context/context'
require_relative 'network/socket'
require_relative 'entity/entity'

include GLSL

@world = Drawing::World.new

touch_supervbo = false
active_render = false

def render
  glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)

  glActiveTexture(GL_TEXTURE0)
  @hmap_texture.bind
  glActiveTexture(GL_TEXTURE1)
  @texture5.bind
  glActiveTexture(GL_TEXTURE2)
  @texture1.bind
  glActiveTexture(GL_TEXTURE3)
  @texture2.bind
  @program4.use
  @program4.uniform_1i("hmap_texture", 0)
  @program4.uniform_1i("texture2", 1)
  @program4.uniform_1i("texture3", 2)
  @program4.uniform_1i("texture4", 3)
  @program4.uniform_matrix4(@world.matrix.world, 'MVP')
  @program4.uniform_matrix4(@world.matrix.model, 'model')

  @landscape4.draw

  @program_cube.use
  @program_cube.uniform_vector(@world.camera.position, 'lightPos')
  @program_cube.uniform_matrix4(@world.matrix.projection, 'projection')
  @program_cube.uniform_matrix4(@world.matrix.view, 'view')
  @instancing.draw

  @cubes.each do |k, cube|
    cube_matrix = @world.matrix.world.translate(cube.x, cube.y, cube.z)
    @program_cube.uniform_matrix4(cube_matrix, 'MVP')
    cube.draw
  end

  # @program_ortho2d.use
  # @program_ortho2d.uniform_matrix4(@mart, 'MVP')

  # glActiveTexture(GL_TEXTURE0)
  # @texture1.bind
  # @program_ortho2d.uniform_1i("texture1", 0)
  # @rect.draw

  # glActiveTexture(GL_TEXTURE0)
  # @texture2.bind
  # @program_ortho2d.uniform_1i("texture1", 0)
  # @rect2.draw

  @program_ortho2d_info.use
  @program_ortho2d_info.uniform_matrix4(@mart, 'MVP')
  glEnable(GL_BLEND)
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)

  glActiveTexture(GL_TEXTURE0)
  @texture_fps.bind
  @program_ortho2d.uniform_1i("texture1", 0)
  @rect_fps.draw

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

vertex_shader = Shader.new(:vertex, Collection::VERTEX_SHADER_S3)
fragment_shader = Shader.new(:fragment, Collection::FRAGMENT_SHADER_S3)
vertex_shader4 = Shader.new(:vertex, Collection::VERTEX_SHADER_S4)
fragment_shader4 = Shader.new(:fragment, Collection::FRAGMENT_SHADER_S4)
vertex_cube_shader = Shader.new(:vertex, Collection::VERTEX_SHADER_CUBE)
fragment_cube_shader = Shader.new(:fragment, Collection::FRAGMENT_SHADER_CUBE)
vertex_ortho2d_shader = Shader.new(:vertex, Collection::VERTEX_SHADER_ORTHO2D)
fragment_ortho2d_shader = Shader.new(:fragment, Collection::FRAGMENT_SHADER_ORTHO2D)
fragment_ortho2d_shader_blend_info = Shader.new(:fragment, Collection::FRAGMENT_SHADER_ORTHO2D_BLEND_INFO)
fragment_ortho2d_shader_menu_edge = Shader.new(:fragment, Collection::FRAGMENT_SHADER_ORTHO2D_MENU_EDGE)

@program4 = Program.new
@program4.attach_shaders(vertex_shader, fragment_shader)
# @program4.attach_shaders(vertex_shader4, fragment_shader4)
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

@program_ortho2d_menu_edge = Program.new
@program_ortho2d_menu_edge.attach_shaders(vertex_ortho2d_shader, fragment_ortho2d_shader_menu_edge)
@program_ortho2d_menu_edge.link

# @world.camera = Drawing::Camera.new(Vector[0.0, 3.0, -10.0], 0.0)
@world.camera = Drawing::Camera.new(Vector[0.0, 0.0, 0.0], 0.0)
@world.matrix.projection = Drawing::Matrix.perspective(55, window.width, window.height, 0.1, 1000.0)
@world.matrix.view = @world.camera.view
@world.matrix.model = Drawing::Matrix.identity(4)

  @texture1 = Drawing::Texture.new
  @texture1.bind
  @texture1.load("./textures/pgrass.bmp")

  @texture2 = Drawing::Texture.new
  @texture2.bind
  @texture2.load("./textures/mf.bmp")

  @hmap_texture = Drawing::Texture.new
  @hmap_texture.bind
  @rawh = @hmap_texture.load("./textures/Rivwide.bmp")
  @rawh = @rawh.unpack "C*"
  @height_map = Calculating::HeightMap.new(0.step(@rawh.size - 1, 3).map { |i| @rawh[i] })
  @world.camera.height_data = @height_map

  @texture5 = Drawing::Texture.new
  @texture5.bind
  @texture5.load("./textures/normalm.bmp")

  font = SDL2::TTF.open('Hack-Bold.ttf', 18, 0)
  @texture_fps = Drawing::Texture.new
  @texture_fps.bind
  sw, sh = @texture_fps.print(font, "FPS: 0.0")
  @rect_fps = Drawing::Object::Rectangle.new(10.0, 450.0, sw, sh)

  @landscape = Drawing::Object::Landscape.new(10)
  @landscape4 = Drawing::Object::Landscape2.new(350)
  @rect = Drawing::Object::Rectangle.new(10.0, 10.0, 100.0, 100.0)
  @rect2 = Drawing::Object::Rectangle.new(10.0, 120.0, 100.0, 100.0)
  @mart = Drawing::Matrix.ortho2d(0.0, window.width, 0.0, window.height)
  @cubes = {}

  @simple_objects = []
  100.times do
    @simple_objects << Entity::Base.new
    sox = rand(350)
    soz = rand(350)
    soy = @height_map.get_y_by(sox, soz) + 0.5
    @simple_objects.last.position = Vector[sox, soy, soz]
  end

  @instancing = Drawing::Object::Instancing.load('./cone.pack', @world, @simple_objects)

  # puts "Landscape size: #{@landscape.size}"

time_a = Process.clock_gettime(Process::CLOCK_MONOTONIC)
frames = 0.0

Context::WindowCallbacks.init(window)
constructor = Context::Constructor.new(window, @world)

SDL2::TextInput.stop

# menu block
menu = Context::Menu.new

menu_item1 = Context::MenuItem.new("Exit")
menu_item1.callback = lambda do
  window.exit
end

menu_item2 = Context::MenuItem.new("Start")
menu_item2.callback = lambda do
  menu.turn_off_state_1
  menu.turn_on_state_2
end

menu.on_exit do
  active_render = true
  glEnable(GL_DEPTH_TEST)
end

menu.add(menu_item1)
menu.add(Context::MenuItem.new('dummy_item'))
menu.add(Context::MenuItem.new('dummy_item'))
menu.add(Context::MenuItem.new('dummy_item'))
menu.add(menu_item2)
menu.font = SDL2::TTF.open('Hack-Regular.ttf', 14, 0)
menu.item_shader = @program_ortho2d_info
menu.focus_shader = @program_ortho2d_menu_edge
menu.matrix = @mart
menu.window = window

network = Network::Client.new(ARGV[0] || '127.0.0.1')
# network = Network::Client.new(ARGV[0] || '127.0.0.1', @cubes)
menu.network = network

menu.setup

pp = Network::Protocol::PacketCamera.new
pp.vector = @world.camera.position.to_a
# network.write [pp]

# You can use OpenGL functions
loop do

  menu.exit
  if true
  # Stub menu render!
  # if active_render
    network.read

    render

    pp.vector = @world.camera.position.to_a
    network.write [pp]
  else
    menu.update
    menu.draw
  end

  window.events_poll
  exit if window.exit?

  window.gl_swap

  if touch_supervbo
    @landscape.update_supervbo
    touch_supervbo = false
  end

  @simple_objects.each do |so|
    sox = so.x + rand - 0.5
    soz = so.z + rand - 0.5
    soy = @height_map.get_y_by(sox, soz)
    so.position = Vector[sox, soy, soz]
  end

  # @instancing.update

  frames += 1.0
  time_b = Process.clock_gettime(Process::CLOCK_MONOTONIC)
  delta = time_b - time_a
  if delta > 2.0
    @texture_fps.bind
    sw, sh = @texture_fps.print(font, "FPS: #{(frames / delta).round(2)}")
    @rect_fps.update_vertices(10.0, 450.0, sw, sh)

    time_a = time_b
    frames = 0


  end
end

# Delete the context after using OpenGL functions
context.destroy
