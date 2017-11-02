require 'pry'
require 'nokogiri'
require 'matrix'

RADIAN_IN_DEGREE = Math::PI / 180.0

def rotate
  v = Vector[1, 0, 0].normalize
  x, y, z = v.to_a
  angle = 270.0 * RADIAN_IN_DEGREE
  c = Math::cos(angle)
  s = Math::sin(angle)

  a1 = x*x*(1 - c) + c
  a2 = x*y*(1 - c) - z*s
  a3 = x*z*(1 - c) + y*s

  b1 = y*x*(1 - c) + z*s
  b2 = y*y*(1 - c) + c
  b3 = y*z*(1 - c) - x*s

  c1 = z*x*(1 - c) - y*s
  c2 = z*y*(1 - c) + x*s
  c3 = z*z*(1 - c) + c
  Matrix.identity(3) * Matrix[
    [a1, a2, a3],
    [b1, b2, b3],
    [c1, c2, c3]
  ]
end

# doc = Nokogiri::XML(File.open("cube.dae")) do |config|
doc = Nokogiri::XML(File.open("cone.dae")) do |config|
  config.strict.noblanks.huge
end

geometry = doc.at_css('library_geometries').child
polylist = geometry.at_css('polylist')
vertex_input = polylist.at_css('input[@semantic="VERTEX"]')
normal_input = polylist.at_css('input[@semantic="NORMAL"]')

# Get transform matrix
idh = "#" + geometry.attribute('id').value
transformation = doc.at_css("instance_geometry[@url='#{idh}']")
raw_data = transformation.parent.at_css('matrix[@sid="transform"]').text.split.map(&:to_f)
r0 = raw_data.shift(4)
r1 = raw_data.shift(4)
r2 = raw_data.shift(4)
matrix = Matrix[r0.take(3),
                r1.take(3),
                r2.take(3)]

# Get vertices
source = vertex_input.attribute('source').value
vertices_input = geometry.at_css(source).at_css('input[@semantic="POSITION"]')
source = vertices_input.attribute('source').value
float_array = geometry.at_css(source).at_css('float_array')
raw_data = float_array.text.split.map(&:to_f)
vertices = []
while raw_data.any? do
  vertices << (matrix * Vector[*raw_data.shift(3)]).to_a
end

# Get normals
source = normal_input.attribute('source').value
float_array = geometry.at_css(source).at_css('float_array')
raw_data = float_array.text.split.map(&:to_f)
normals = []
rotate_matrix = rotate
while raw_data.any? do
  normals << (rotate_matrix * Vector[*raw_data.shift(3)]).normalize.to_a
end

# Get build data
indices = polylist.at_css('p').text.split.map(&:to_i)
data = []
elements_count = 0
while indices.any? do
  v, n = indices.shift(2)
  data.concat vertices[v]
  data.concat normals[n]
  elements_count += 3
end

# binding.pry


# file = File.open("../cube.obj", "r")
# vertices = []
# normals = []
# data = []
# elements_count = 0

# while !file.eof? do
#   fields = file.readline.split(' ')
#   case fields[0]
#   when "v"
#     vertices << fields[1..3].map(&:to_f)
#   when "vn"
#     normals << fields[1..3].map(&:to_f)
#   when "f"
#     fields[1..3].each do |field|
#       vi, vni = field.split('//').map(&:to_i)
#       data.concat vertices[vi - 1]
#       data.concat normals[vni - 1]
#     end
#     elements_count += 3
#   end
# end

File.open("cone.pack", 'wb' ) do |output|
  output.write [elements_count].pack('I')
  output.write data.pack('F*')
end
