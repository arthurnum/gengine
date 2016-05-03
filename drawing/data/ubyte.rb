module Drawing
  module Data
    class UByte < Data::Base
      def pack_format
        'C*'
      end

      def size
        @data.size
      end
    end
  end
end
