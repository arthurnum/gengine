module Context
  class MenuItem
    attr_accessor :rectangle, :texture, :callback, :title, :next, :previous

    def initialize(title)
      @title = title
    end

    def next=(item)
      @next = item
      item.previous = self
    end

    def submit
      callback.call
    end

    def x
      rectangle.x
    end

    def y
      rectangle.y
    end

    def width
      rectangle.width
    end

    def height
      rectangle.height
    end
  end
end
