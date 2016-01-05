module Drawing
	class Vertex
    attr_accessor :vector, :faces, :color

    def initialize(x, y, z)
      @vector = Vector[x, y, z]
      @color = Vector[0.8, 0.8, 0.8]
      @faces = []
    end

    def normal
      result = Vector[0.0, 0.0, 0.0]
      @faces.each { |f| result += f.normal }
      result.normalize
    end

    def color
      focus ? Vector[0.9, 0.1, 0.1] : Vector[0.8, 0.8, 0.8]
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
