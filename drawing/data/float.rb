module Drawing
  module Data
    class Float < Data::Base
      def pack_format
        'F*'
      end

      def size
        4 * @data.size
      end
    end
  end
end
