module Drawing
  class Triangle
    attr_accessor :focus

    def initialize(v1, v2, v3)
      @vertices = [v1, v2, v3]
      v1.faces << self
      v2.faces << self
      v3.faces << self
    end

    def normal
      @normal ||= calculate_normal
    end

    def reset_normal
      @normal = calculate_normal
    end

    def inspect
      "#{v1.vector}\n#{v2.vector}\n#{v3.vector}"
    end

    def has?(point)
      oa = v1.vector - point
      ob = v2.vector - point
      oc = v3.vector - point
      ab = v2.vector - v1.vector
      ac = v3.vector - v1.vector
      oa.cross(ob).r + ob.cross(oc).r + oc.cross(oa).r <= ab.cross(ac).r
    end

    def color=(vcolor)
      v1.color = v2.color = v3.color = vcolor
    end

    def v1
      @vertices[0]
    end

    def v2
      @vertices[1]
    end

    def v3
      @vertices[2]
    end

    def each_vertex
      @vertices.each { |v| yield v }
    end

    private

    def calculate_normal
      t1 = v2.vector - v1.vector
      t2 = v3.vector - v1.vector
      result = t1.cross_product t2
      result.normalize
    end
  end
end
