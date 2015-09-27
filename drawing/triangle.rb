module Drawing
  class Triangle

    def initialize(v1, v2, v3)
      @vertices = [v1, v2, v3]
      v1.faces << self
      v2.faces << self
      v3.faces << self
    end

    def normal
      t1 = v2.vector - v1.vector
      t2 = v3.vector - v1.vector
      result = t1.cross_product t2
      result.normalize
    end

    private

    def v1
      @vertices[0]
    end

    def v2
      @vertices[1]
    end

    def v3
      @vertices[2]
    end
  end
end