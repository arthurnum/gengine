module Calculating
  class Voxel
    attr_accessor :faces

    def initialize(vmin, vmax)
      @vmin = vmin
      @vmax = vmax
      @faces = []
    end

    def include?(face)
      return (face.v1.x >= @vmin[0] && face.v1.x <= @vmax[0]) &&
        (face.v1.y >= @vmin[1] && face.v1.y <= @vmax[1]) &&
        (face.v1.z >= @vmin[2] && face.v1.z <= @vmax[2])
    end

    def add_face(face)
      @faces << face
    end

    def ray_intersect(ray)
      if box_intersect?(ray)
        return ray.intersection(@faces)
      end

      nil
    end

    def box_intersect?(ray)
      tmin = (@vmin[0] - ray.near[0]) / ray.far[0]
      tmax = (@vmax[0] - ray.near[0]) / ray.far[0]

      if (tmin > tmax)
        buf = tmin
        tmin = tmax
        tmax = buf
      end

      tymin = (@vmin[1] - ray.near[1]) / ray.far[1]
      tymax = (@vmax[1] - ray.near[1]) / ray.far[1]

      if (tymin > tymax)
        buf = tymin
        tymin = tymax
        tymax = buf
      end

      return false if ((tmin > tymax) || (tymin > tmax))

      tmin = tymin if (tymin > tmin)

      tmax = tymax if (tymax < tmax)

      tzmin = (@vmin[2] - ray.near[2]) / ray.far[2]
      tzmax = (@vmax[2] - ray.near[2]) / ray.far[2]

      if (tzmin > tzmax)
        buf = tzmin
        tzmin = tzmax
        tzmax = buf
      end

      return false if ((tmin > tzmax) || (tzmin > tmax))

      return true
    end
  end
end
