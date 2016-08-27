module Drawing
  class View
    attr_accessor :allocation, :model, :angle

    def initialize(world)
      @world = world
      @angle = 0.0
    end

    def allocate
      allocation.call self, @world
    end

    def matrix
      @world.matrix.projection * @world.matrix.view * model
    end
  end
end
