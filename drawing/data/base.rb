module Drawing
  module Data
    class Base
      attr_reader :pack_format, :size

      def initialize(data)
        @data = data
      end

      def pack
        @data.pack(pack_format)
      end
    end
  end
end
