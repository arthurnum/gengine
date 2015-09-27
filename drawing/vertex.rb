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
  end
end