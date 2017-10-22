module Drawing
  require 'matrix'

  class Matrix < Matrix

    def translate(x, y, z)
      self * Drawing::Matrix[[1.0, 0.0, 0.0, x],[0.0, 1.0, 0.0, y],[0.0, 0.0, 1.0, z],[0.0, 0.0, 0.0, 1.0]]
    end

    def rotate(angle, x, y, z)
      v = Vector[x, y, z].normalize
      x, y, z = v.to_a
      angle = angle.to_rad
      c = Math::cos(angle)
      s = Math::sin(angle)

      a1 = x*x*(1 - c) + c
      a2 = x*y*(1 - c) - z*s
      a3 = x*z*(1 - c) + y*s

      b1 = y*x*(1 - c) + z*s
      b2 = y*y*(1 - c) + c
      b3 = y*z*(1 - c) - x*s

      c1 = z*x*(1 - c) - y*s
      c2 = z*y*(1 - c) + x*s
      c3 = z*z*(1 - c) + c
      self * Drawing::Matrix[
        [a1, a2, a3, 0],
        [b1, b2, b3, 0],
        [c1, c2, c3, 0],
        [ 0,  0,  0, 1]
      ]
    end

    def data
      @data ||= self.to_a.flatten.pack('F*')
    end

    class << self
      def perspective(angle, w, h, near, far)
        aspect = w / h
        angle_rad = angle.to_rad
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

      def ortho2d(left, right, bottom, top)
        a1 = 2 / (right - left)
        a2 = 2 / (top - bottom)
        a3 = -1
        tx = -(right + left) / (right - left)
        ty = -(top + bottom) / (top - bottom)
        tz = 0

        Drawing::Matrix[
          [a1, 0.0, 0.0, tx],
          [0.0, a2, 0.0, ty],
          [0.0, 0.0, a3, tz],
          [0.0, 0.0, 0.0, 1.0]
        ]
      end
    end
  end
end
