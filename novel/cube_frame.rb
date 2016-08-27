module Novel
  class CubeFrame
    attr_accessor :switch_frame_on

    def initialize(world)
      @world = world
      @switch_frame_on = false
      @angle = 0.0

      vertex_ortho2d_shader = Shader.new(:vertex, Collection::VERTEX_SHADER_ORTHO2D)
      fragment_ortho2d_shader = Shader.new(:fragment, Collection::FRAGMENT_SHADER_ORTHO2D)

      @program_ortho2d = Program.new
      @program_ortho2d.attach_shaders(vertex_ortho2d_shader, fragment_ortho2d_shader)
      @program_ortho2d.link

      @texture1 = Drawing::Texture.new
      @texture1.bind
      @texture1.load("./textures/ccw.bmp")

      @texture2 = Drawing::Texture.new
      @texture2.bind
      @texture2.load("./textures/mf.bmp")

      @texture3 = Drawing::Texture.new
      @texture3.bind
      @texture3.load("./textures/st.bmp")

      @texture4 = Drawing::Texture.new
      @texture4.bind
      @texture4.load("./textures/sw.bmp")

      @view1 = Drawing::View.new(@world)
      @view1.angle = @angle
      @view1.allocation = lambda do |v, world|
        v.model = world.matrix.model.translate(0.0, 0.0, 1.5).rotate(v.angle, 0.0, 1.0, 0.0)
      end
      @view1.allocate

      @view2 = Drawing::View.new(@world)
      @view2.angle = @angle + 270.0
      @view2.allocation = lambda do |v, world|
        v.model = world.matrix.model.translate(0.0, 0.0, 1.5).rotate(v.angle, 0.0, 1.0, 0.0)
      end
      @view2.allocate

      @view3 = Drawing::View.new(@world)
      @view3.angle = @angle + 180.0
      @view3.allocation = lambda do |v, world|
        v.model = world.matrix.model.translate(0.0, 0.0, 1.5).rotate(v.angle, 0.0, 1.0, 0.0)
      end
      @view3.allocate

      @view4 = Drawing::View.new(@world)
      @view4.angle = @angle + 90.0
      @view4.allocation = lambda do |v, world|
        v.model = world.matrix.model.translate(0.0, 0.0, 1.5).rotate(v.angle, 0.0, 1.0, 0.0)
      end
      @view4.allocate

      @rect1 = Drawing::Object::Rectangle3D.new([
        Drawing::Vertex.new(-0.5, -0.5, -0.5),
        Drawing::Vertex.new(0.5, -0.5, -0.5),
        Drawing::Vertex.new(-0.5, 0.5, -0.5),
        Drawing::Vertex.new(0.5, 0.5, -0.5)
      ])
    end

    def draw
      @program_ortho2d.use
      @program_ortho2d.uniform_1i("texture1", 0)

      @program_ortho2d.uniform_matrix4(@view1.matrix, 'MVP')
      glActiveTexture(GL_TEXTURE0)
      @texture1.bind
      @rect1.draw

      @program_ortho2d.uniform_matrix4(@view2.matrix, 'MVP')
      glActiveTexture(GL_TEXTURE0)
      @texture2.bind
      @rect1.draw

      @program_ortho2d.uniform_matrix4(@view3.matrix, 'MVP')
      glActiveTexture(GL_TEXTURE0)
      @texture3.bind
      @rect1.draw

      @program_ortho2d.uniform_matrix4(@view4.matrix, 'MVP')
      glActiveTexture(GL_TEXTURE0)
      @texture4.bind
      @rect1.draw
    end

    def rotate(a)
      return unless switch_frame_on
      @angle += a
      update_views
    end

    def switch_frame
      case @angle % 360
      when (45...135)
        @angle = 90.0
      when (135...225)
        @angle = 180.0
      when (225...315)
        @angle = 270.0
      else
        @angle = 0.0
      end

      update_views
    end

    def update_views
      @view1.angle = @angle
      @view2.angle = @angle + 270.0
      @view3.angle = @angle + 180.0
      @view4.angle = @angle + 90.0

      @view1.allocate
      @view2.allocate
      @view3.allocate
      @view4.allocate
    end
  end
end
