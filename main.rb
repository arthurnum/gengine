require 'sdl2'
require 'opengl'
require 'glu'

require 'pry'


OpenGL.load_lib
GLU.load_lib
include OpenGL
include GLU

require_relative 'glsl/glsl'
require_relative 'drawing/drawing'
require_relative 'calculating/calculating'

include GLSL

vertex_shader_code = %q(
    #version 330 core
    layout(location=0) in vec3 pos;
    layout(location=1) in vec3 normal;
    uniform mat4 MVP;
    uniform mat4 M;
    uniform mat4 V;
    uniform vec3 rayNear;
    uniform vec3 rayFar;

    out vec4 cursorColor;
    out float light_K;

    void ray_is_near(out float outputValue)
    {
      vec3 s = rayFar - rayNear;
      vec3 mo = rayFar - pos;
      vec3 ss = cross(mo, s);
      float d = length(ss) / length(s);

      outputValue = clamp( d / 0.15, 0.0, 1.0 );
    }

    void main()
    {
      vec3 light_source = vec3(3.0, 10.0, 0.0);

      // Vector that goes from the vertex to the camera, in camera space.
      // In camera space, the camera is at the origin (0,0,0).
      vec3 vertexPosition_cameraspace = ( V * M * vec4(pos, 1)).xyz;
      vec3 EyeDirection_cameraspace = vec3(0.0,0.0,0.0) - vertexPosition_cameraspace;

      // Vector that goes from the vertex to the light, in camera space. M is ommited because it's identity.
      vec3 LightPosition_cameraspace = ( V * vec4(light_source, 1)).xyz;
      vec3 LightDirection_cameraspace = LightPosition_cameraspace + EyeDirection_cameraspace;

      // Normal of the the vertex, in camera space
      // Only correct if ModelMatrix does not scale the model ! Use its inverse transpose if not.
      vec3 Normal_cameraspace = ( V * M * vec4(normal, 0)).xyz;

      // Normal of the computed fragment, in camera space
      vec3 n = normalize( Normal_cameraspace );
      // Direction of the light (from the fragment to the light)
      vec3 l = normalize( LightDirection_cameraspace );

      light_K = clamp( dot(n, l), 0, 1 );
      gl_Position = MVP * vec4(pos, 1.0);

      float a = 0.0;
      ray_is_near(a);
      cursorColor = mix(vec4(1.0, 0.0, 0.0, 1.0), vec4(0.8, 0.8, 0.8, 1.0), a);
    }
  )

fragment_shader_code = %q(
    #version 330 core
    in float light_K;
    in vec4 cursorColor;

    out vec4 out_color;
    void main()
    {
      vec4 materialColor = cursorColor;
      vec4 materialAmbientColor = vec4(0.1, 0.1, 0.1, 1.0) * materialColor;
      vec4 lightColor = vec4(1.0, 1.0, 1.0, 1.0);
      out_color = materialAmbientColor + materialColor * lightColor * light_K;
    }
  )

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
window = SDL2::Window.create('GENGINE', 0, 0, 1024, 768,
                             (SDL2::Window::Flags::OPENGL | SDL2::Window::Flags::RESIZABLE))


# Create a OpenGL context attached to the window
context = SDL2::GL::Context.create(window)

glViewport(0, 0, 1024, 768)
glClearColor(0,0,0,0)
glEnable(GL_DEPTH_TEST)


vertex_shader = Shader.new(:vertex, vertex_shader_code)
fragment_shader = Shader.new(:fragment, fragment_shader_code)

@program = Program.new
@program.attach_shaders(vertex_shader, fragment_shader)
@program.link_and_use

@world.matrix.projection = Drawing::Matrix.perspective(65, 1024.0, 768.0, 0.1, 10.0)
@world.matrix.view = Drawing::Matrix.look_at(Vector[0.0, 0.5, 1.0], Vector[0.0, 0.0, -5.0], Vector[0.0, 1.0, 0.0])
@world.matrix.model = Drawing::Matrix.identity(4)

@program.uniform_matrix4(@world.matrix.world, 'MVP')

  vao = '    '
  glGenVertexArrays(1, vao)
  glBindVertexArray(vao.unpack('L')[0])

  landscape = Drawing::Object::Landscape.new(50)

  vbo = Drawing::VBO.new(:vertex)
  vbo.bind
  vbo.data(landscape.vertices_data)
  glEnableVertexAttribArray(0)
  glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 0, 0)

  vbo = Drawing::VBO.new(:vertex)
  vbo.bind
  vbo.data(landscape.normals_data)
  glEnableVertexAttribArray(1)
  glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, 0, 0)

  vbo2 = Drawing::VBO.new(:index)
  vbo2.bind
  vbo2.data(landscape.indices_data)

  @count = landscape.size

model_mode = false

time_a = Time.now
frames = 0.0

# You can use OpenGL functions
loop do
  render
  while ev = SDL2::Event.poll
    if SDL2::Event::KeyDown === ev && ev.scancode == SDL2::Key::Scan::ESCAPE
      exit
    end
    if SDL2::Event::Window === ev && ev.event == SDL2::Event::Window::RESIZED
      p 'Augh! RESIZED!'
    end
    if SDL2::Event::MouseButtonDown === ev
      ray = Calculating::Ray.new
      ray.trace(@world.matrix.world, 1024.0, 768.0, ev.x, 768 - ev.y)
      @program.uniform_vector(ray.near, 'rayNear')
      @program.uniform_vector(ray.far, 'rayFar')
    end
    if SDL2::Event::MouseButtonUp === ev && ev.clicks > 1
      model_mode = !model_mode
      p "Model mode #{model_mode ? 'ON' : 'OFF'}"
    end
    if SDL2::Event::MouseMotion === ev && model_mode
      @world.matrix.view = @world.matrix.view.translate(ev.xrel*0.01, -ev.yrel*0.01, 0.0)
    end
    if SDL2::Event::MouseWheel === ev && model_mode
      @world.matrix.view = @world.matrix.view.translate(0.0, 0.0, -ev.y*0.1)
    end
  end
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
