module Drawing
  require 'matrix'

  class Matrix < Matrix
    def translate(x, y, z)
      self * Drawing::Matrix[[1.0, 0.0, 0.0, x],[0.0, 1.0, 0.0, y],[0.0, 0.0, 1.0, z],[0.0, 0.0, 0.0, 1.0]]
    end

    class << self
      def perspective(angle, w, h, near, far)
        aspect = w / h
        angle_rad = angle * Math::PI / 180.0
        fovy = angle_rad / 2.0
        f = Math.cos(fovy) / Math.sin(fovy)
        u1 = (far + near) / (near - far)
        u2 = (2.0 * far * near) / (near - far)
        self[[(f/aspect),0.0,0.0,0.0], [0.0,f,0.0,0.0], [0.0,0.0,u1,u2], [0.0,0.0,-1.0,0.0]]
      end

      def look_at(eye, center, up)
        f = center - eye
        f = f.normalize

        s = up.cross_product f
        s = s.normalize

        u = f.cross_product s
        u = u.normalize

        f *= -1
        eye *= -1

        Drawing::Matrix[[*s, 0.0],[*u, 0.0],[*f, 0.0],[0.0,0.0,0.0,1.0]].translate(*eye)
      end
    end
  end
end
