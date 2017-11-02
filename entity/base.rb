module Entity
  class Base
    attr_accessor :position

    def initialize
      self.position = Vector[0, 0, 0]
    end

    def x; position[0]; end
    def y; position[1]; end
    def z; position[2]; end
  end
end
