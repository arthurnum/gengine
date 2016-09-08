module Network
  module Protocol
    # Gengine daemon protocol
    VERSION = '0.01'.freeze
    HEADER = "GDP #{VERSION}".freeze

    IN = 1

    CODE_TO_PACKET = {
      IN => "Network::Protocol::PacketIn"
    }

    def self.parse(msg)
      code = msg.unpack("c")[0]

      Object.const_get(CODE_TO_PACKET[code]).unpack(msg)
    end

    class PacketIn
      DATA_FORMAT = "c A64"

      attr_accessor :username

      def initialize
        @code = Protocol::IN
      end

      def self.unpack(msg)
        data = msg.unpack(DATA_FORMAT)
        packet = self.new
        packet.username = data[1]
        packet
      end

      def pack
        data = [@code]
        data << "%-64s" % username
        data.pack DATA_FORMAT
      end

      def info
        "IN: #{username}"
      end
    end
  end
end
