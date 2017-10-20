require 'pry'

file = File.open("../cube.obj", "r")
vertices = []File.open("../cube.pack"
normals = []
data = []
elements_count = 0

while !file.eof? do
  fields = file.readline.split(' ')
  case fields[0]
  when "v"
    vertices << fields[1..3].map(&:to_f)
  when "vn"
    normals << fields[1..3].map(&:to_f)
  when "f"
    fields[1..3].each do |field|
      vi, vni = field.split('//').map(&:to_i)
      data.concat vertices[vi - 1]
      data.concat normals[vni - 1]
    end
    elements_count += 3
  end
end

File.open("../cube.pack", 'wb' ) do |output|
  output.write [elements_count].pack('I')
  output.write data.pack('F*')
end
