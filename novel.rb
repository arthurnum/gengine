require 'sdl2'
require 'opengl'

require 'pry'

OpenGL.load_lib
include OpenGL

require_relative 'glsl/glsl'
require_relative 'drawing/drawing'
require_relative 'calculating/calculating'
require_relative 'context/context'
require_relative 'novel/novel'

include GLSL

@world = Drawing::World.new

touch_supervbo = false

def render
  glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)

  @cube_frame.draw
end

SDL2.init(SDL2::INIT_EVERYTHING)
SDL2::GL.set_attribute(SDL2::GL::DOUBLEBUFFER, 1)
SDL2::GL.set_attribute(SDL2::GL::CONTEXT_MAJOR_VERSION, 3)
SDL2::GL.set_attribute(SDL2::GL::CONTEXT_MINOR_VERSION, 3)
SDL2::GL.set_attribute(SDL2::GL::CONTEXT_PROFILE_MASK, SDL2::GL::CONTEXT_PROFILE_CORE)

# You need to create a window with `OPENGL' flag
window = Context::Window.new(1024.0, 1024.0)

# Create a OpenGL context attached to the window
context = SDL2::GL::Context.create(window.sdl_window)

glViewport(0, 0, window.width, window.height)
glClearColor(0,0,0,0)
glEnable(GL_DEPTH_TEST)

@world.camera = Drawing::CameraZ.new
@world.matrix.projection = Drawing::Matrix.perspective(53, window.width, window.height, 0.1, 100.0)
@world.matrix.view = @world.camera.view
@world.matrix.model = Drawing::Matrix.identity(4)

  @cube_frame = Novel::CubeFrame.new(@world)

time_a = Time.now
frames = 0.0

Context::WindowCallbacks.init(window)

h_camera_flee = lambda do |win, ev|
  if ev.scancode == SDL2::Key::Scan::LCTRL
    @world.camera.flee
    @cube_frame.switch_frame_on = true
  end
end

h_camera_return = lambda do |win, ev|
  if ev.scancode == SDL2::Key::Scan::LCTRL
    @world.camera.return
    @cube_frame.switch_frame_on = false
    @cube_frame.switch_frame
  end
end

h_mouse_motion = lambda do |win, ev|
  @cube_frame.rotate(ev.xrel * -0.25)
end

h_mouse_down = lambda do |win, ev|
  ray = Calculating::Ray.new
  ray.trace(@world.matrix.world, window.width, window.height, ev.x, window.height - ev.y)
end

window.register_event_handler(:key_down, h_camera_flee)
window.register_event_handler(:key_up, h_camera_return)
window.register_event_handler(:mouse_motion, h_mouse_motion)
window.register_event_handler(:mouse_button_down, h_mouse_down)

# You can use OpenGL functions
loop do
  render

  window.events_poll
  exit if window.exit?

  window.gl_swap

  @world.update

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
