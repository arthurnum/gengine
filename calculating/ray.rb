module Calculating
  class Ray
    attr_reader :near, :far

    def trace(modelview, proj, w, h, winX, winY)
      world_matrix = (proj * modelview).inverse
      x = winX * 2.0 / w - 1.0
      y = winY * 2.0 / h - 1.0
      @near = Vector[(world_matrix * Vector[x, y, -1.0, 1.0]).take(3)]
      @far = Vector[(world_matrix * Vector[x, y, 1.0, 1.0]).take(3)]
    end
  end
end
