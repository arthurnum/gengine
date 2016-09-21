class DiamondSquare
  def initialize(size)
    @size = size
    @data = Array.new(size * size)
  end

  def generate
    last = @size - 1
    @data[0] = rnd
    @data[last] = rnd
    @data[last * @size] = rnd
    @data[-1] = rnd

    divide(@size)

    self
  end

  def smooth
    row = 0
    while row < @size - 1

      col = 0
      while col < @size - 1
        a = row * @size + col
        b = row * @size + col + 1
        c = (row + 1) * @size + col
        d = (row + 1) * @size + col + 1

        h = (@data[a] + @data[b] + @data[c] + @data[d]) / 4

        @data[a] = h
        @data[b] = h
        @data[c] = h
        @data[d] = h

        col += 1
      end

      row += 1
    end

    self
  end

  def pixels_24bits
    @data.map do |i|
      j = (256 * i).floor
      j = 255 if j > 255
      j = 0 if j < 0
      [j, j, j]
    end.flatten.pack("C*")
  end

  def to_s; self.class.to_s; end
  def inspect; self.to_s; end

  private

  def divide(step_size)
    half = step_size / 2

    return if half < 1

    row = half
    while row < @size

      col = half
      while col < @size
        square(row, col, half)

        col += step_size
      end

      row += step_size
    end

    divide(half)
  end

  def square(row, col, size)
    a = @data[(row - size) * @size + col - size] || rnd
    b = @data[(row - size) * @size + col + size] || rnd
    c = @data[(row + size) * @size + col - size] || rnd
    d = @data[(row + size) * @size + col + size] || rnd

    h = (a + b + c + d) / 4 + rndr

    @data[row * @size + col] = h.round(2)

    diamond(row, col + size, size)
    diamond(row, col - size, size)
    diamond(row + size, col, size)
    diamond(row - size, col, size)
  end

  def diamond(row, col, size)
    a = @data[row * @size + col - size] || rnd
    b = @data[row * @size + col + size] || rnd
    c = @data[(row - size) * @size + col] || rnd
    d = @data[(row + size) * @size + col] || rnd

    h = (a + b + c + d) / 4 + rndr

    @data[row * @size + col] = h.round(2)
  end

  def rnd
    rand.round(2)
  end

  def rndr
    rand((-0.33..0.33))
  end

end
