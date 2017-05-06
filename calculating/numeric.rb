class Numeric
  RADIAN_IN_DEGREE = Math::PI / 180.0

  def to_rad
    self * RADIAN_IN_DEGREE
  end
end
