module Drawing
  module Data
    class UInt < Data::Base
      def pack_format
        'I*'
      end

      def size
        4 * @data.size
      end
    end
  end
end
