module Drawing
  require 'matrix'

  class Matrix < Matrix
    class << self
      def perspective(angle, w, h, near, far)
        aspect = w / h
        angle_rad = angle * Math::PI / 180.0
        fovy = angle_rad / 2.0
        f = Math.cos(fovy) / Math.sin(fovy)
        u1 = (far + near) / (near - far)
        u2 = (2.0 * far * near) / (near - far)
        self[[(f/aspect),0,0,0], [0,f,0,0], [0,0,u1,u2], [0,0,-1,0]]
      end
    end
  end
end
