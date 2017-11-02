module Drawing
  module Object
    class Instancing
      def self.load(file_name, world, list)
        bin_data = File.binread(file_name)
        elements_count, *data = bin_data.unpack('I F*')
        new(elements_count, data, world, list)
      end

      def initialize(elements_count, data, world, list)
        @elements_count = elements_count
        @instances_count = list.size
        @list = list
        @world = world

        offset_data = list.map do |simple_object|
          world.matrix.model.translate(simple_object.x, simple_object.y, simple_object.z).transpose.data
        end.join

        @vao = Drawing::VAO.new
        @vao.bind

        @vbo = Drawing::VBO.new(:vertex)
        @vbo.bind
        @vbo.data(Data::Float.new(data))
        @vao.set_array_pointer(0, 3, GL_FLOAT, GL_FALSE, 24, 0)
        @vao.set_array_pointer(1, 3, GL_FLOAT, GL_FALSE, 24, 12)

        @vbo_offset = Drawing::VBO.new(:vertex)
        @vbo_offset.bind
        @vbo_offset.raw_data(offset_data.size, offset_data)

        @vao.set_array_pointer(2, 4, GL_FLOAT, GL_FALSE, 64, 0)
        @vao.set_array_pointer(3, 4, GL_FLOAT, GL_FALSE, 64, 16)
        @vao.set_array_pointer(4, 4, GL_FLOAT, GL_FALSE, 64, 32)
        @vao.set_array_pointer(5, 4, GL_FLOAT, GL_FALSE, 64, 48)
        divisior = 1
        glVertexAttribDivisor(2, divisior);
        glVertexAttribDivisor(3, divisior);
        glVertexAttribDivisor(4, divisior);
        glVertexAttribDivisor(5, divisior);
      end

      def draw
        @vao.bind
        glDrawArraysInstanced(GL_TRIANGLES, 0, @elements_count, @instances_count)
      end

      def update
        offset_data = @list.map do |simple_object|
          @world.matrix.model.translate(simple_object.x, simple_object.y, simple_object.z).transpose.data
        end.join

        @vbo_offset.bind
        @vbo_offset.raw_data(offset_data.size, offset_data)
      end

    end
  end
end
