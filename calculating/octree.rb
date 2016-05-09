module Calculating
  class Octree

    class Node
      attr_accessor :parent, :children, :voxel

      def initialize; yield self; end

      def ray_intersect(ray)
        voxel.ray_intersect(ray)
      end

      def include?(face)
        voxel.include?(face)
      end

      def add_face(face)
        voxel.add_face(face)
      end
    end

    attr_accessor :roots, :focus_array, :focus_array_vertices

    def initialize
      @roots = []
      @focus_array = []
      @focus_array_vertices = []
    end

    def build_by(options)
      @roots = []
      dim = options[:dim]
      v = options[:voxel_size]
      yd = v / 2.0
      z = 0.0

      while z < dim
        x = 0.0

        while x < dim
          node = Node.new do |n|
            n.voxel = Voxel.new(
              Vector[x, 0 - yd, z],
              Vector[x + v, 0 + yd, z + v])
          end

          @roots << node
          x += v
        end

        z += v
      end
    end

    def add_face(face)
      @roots.each do |node|
        node.add_face(face) if node.include?(face)
      end
    end

    def ray_intersect(ray)
      @focus_array.each { |face| face.focus = false }
      @focus_array = []
      @focus_array_vertices = []

      @roots.each do |node|
        result = node.ray_intersect(ray)
        next unless result

        if result.any?
          set_focus(result)
          break
        end
      end
    end

    private

    def set_focus(array)
      @focus_array = array
      array.each do |face|
        face.focus = true
        @focus_array_vertices.concat face.vertices
      end
      @focus_array_vertices.uniq!
    end
  end
end
