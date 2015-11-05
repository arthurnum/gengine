module Drawing
	class Vertex
    attr_accessor :vector, :faces

    def initialize(x, y, z)
      @vector = Vector[x, y, z]
      @faces = []
    end

    def normal
      result = Vector[0.0, 0.0, 0.0]
      @faces.each { |f| result += f.normal }
      result.normalize
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
