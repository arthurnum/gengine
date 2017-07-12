module Context
  class InputBox
    MAX_LENGTH = 22
    attr_accessor :rectangle, :texture, :text

    def self.generate(x, y, font, text)
      box = new
      box.texture = Drawing::Texture.new
      box.texture.bind
      w, h = box.update(font, text)
      box.rectangle = Drawing::Object::Rectangle.new(x, y, w, h)
      box
    end

    def update(font, text)
      self.text = text[0...MAX_LENGTH]
      texture.print(font, format)
    end

    def add(font, text)
      update(font, self.text + text)
    end

    def chop(font)
      update(font, self.text.chop)
    end

    def format
      "%-#{MAX_LENGTH}s" % text
    end
  end
end
