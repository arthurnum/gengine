module Drawing
	class Vertex
    attr_accessor :vector, :faces, :color, :uva

    def initialize(x, y, z)
      @vector = Vector[x, y, z]
      @color = Vector[1.0, 1.0, 1.0]
      @uva = 0
      @faces = []
    end

    def normal
      result = Vector[0.0, 0.0, 0.0]
      @faces.each { |f| result += f.normal }
      result.normalize
    end

    def color
      focus ? Vector[1.0, 1.0, 0.6] : Vector[1.0, 1.0, 1.0]
    end

    def focus
      faces.map(&:focus).include? true
    end

    def x
      @vector[0]
    end

    def y
      @vector[1]
    end

    def z
      @vector[2]
    end

  end
end
