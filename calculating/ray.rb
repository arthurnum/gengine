module Calculating
  class Ray
    attr_reader :near, :far, :direct

    def trace(world, w, h, winX, winY)
      world_matrix = world.inverse
      x = winX * 2.0 / w - 1.0
      y = winY * 2.0 / h - 1.0
      @near = clip(world_matrix, Vector[x, y, -1.0, 1.0])
      @far = clip(world_matrix, Vector[x, y, 1.0, 1.0])
      @direct = @near - @far
    end

    ###
    # Trace equation
    # x = t * @direct[0] + @far[0]
    # y = t * @direct[1] + @far[1]
    # z = t * @direct[2] + @far[2]
    #
    # Face equation
    # normal[0]*(x - v1[0]) + normal[1]*(y - v1[1]) + normal[2]*(z - v1[2]) = 0
    # normal[0]*x - normal[0]*v[0] + normal[1]*y - normal[1]*v[1] + normal[2]*z - normal[2]*v[2] = 0
    # normal[0]*x + normal[1]*y + normal[2]*z = normal[0]*v[0] + normal[1]*v[1] + normal[2]*v[2]
    # normal[0]*x + normal[1]*y + normal[2]*z = face_d
    # normal[0]*direct[0]*t + normal[1]*direct[1]*t + normal[2]*direct[2]*t = face_d - outbound
    # t * ( normal[0]*direct[0] + normal[1]*direct[1] + normal[2]*direct[2] ) = face_d - outbound
    # t = (face_d - outbound) / k
    ###
    def intersection(faces)
      result = []
      faces.each do |tr|
        face_d = tr.normal[0] * tr.v1.x + tr.normal[1] * tr.v1.y + tr.normal[2] * tr.v1.z
        outbound = tr.normal[0] * far[0] + tr.normal[1] * far[1] + tr.normal[2] * far[2]
        k = tr.normal[0] * direct[0] + tr.normal[1] * direct[1] + tr.normal[2] * direct[2]
        t = (face_d - outbound) / k
        x = t * @direct[0] + @far[0]
        y = t * @direct[1] + @far[1]
        z = t * @direct[2] + @far[2]
        point = Vector[x, y, z]
        tr.focus = tr.has?(point)
        result << tr if tr.focus
      end
      result
    end

    def box_intersect
      tmin = (0.0 - near[0]) / far[0]
      tmax = (10.0 - near[0]) / far[0]

      if (tmin > tmax)
        buf = tmin
        tmin = tmax
        tmax = buf
      end

      tymin = (-5.0 - near[1]) / far[1]
      tymax = (5.0 - near[1]) / far[1]

      if (tymin > tymax)
        buf = tymin
        tymin = tymax
        tymax = buf
      end

      return false if ((tmin > tymax) || (tymin > tmax))

      tmin = tymin if (tymin > tmin)

      tmax = tymax if (tymax < tmax)

      tzmin = (0.0 - near[2]) / far[2]
      tzmax = (10.0 - near[2]) / far[2]

      if (tzmin > tzmax)
        buf = tzmin
        tzmin = tzmax
        tzmax = buf
      end

      return false if ((tmin > tzmax) || (tzmin > tmax))

      return true
    end

    private

    def clip(matrix, v)
      c = matrix * v
      c /= c[3]
      Vector[*(c.take(3))]
    end
  end
end
