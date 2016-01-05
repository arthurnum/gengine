module Drawing
  class Triangle

    def initialize(v1, v2, v3)
      @vertices = [v1, v2, v3]
      v1.faces << self
      v2.faces << self
      v3.faces << self
    end

    def normal
      @normal ||= calculate_normal
    end

    def inspect
      "#{v1.vector}\n#{v2.vector}\n#{v3.vector}"
    end

    def has?(point)
      # a = point - v1.vector
      # b = point - v2.vector
      # e1 = a.cross(b).dot(normal)
      #   a = point - v2.vector
      #   b = point - v3.vector
      #   e2 = a.cross(b).dot(normal)
      #     a = point - v3.vector
      #     b = point - v1.vector
      #     e3 = a.cross(b).dot(normal)
      # return true if (e1 > 0) && (e2 > 0) && (e3 > 0)
      # return true if (e1 < 0) && (e2 < 0) && (e3 < 0)
      # return false
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

    private

    def calculate_normal
      t1 = v2.vector - v1.vector
      t2 = v3.vector - v1.vector
      result = t1.cross_product t2
      result.normalize
    end
  end
end
