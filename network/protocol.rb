module Network
  module Protocol
    # Gengine daemon protocol
    VERSION = '0.01'.freeze
    HEADER = "GDP #{VERSION}".freeze

    IN = 1
    CUBE_REQUEST = 2
    CUBE_RESPONSE = 3

    CODE_TO_PACKET = {
      IN => "Network::Protocol::PacketIn",
      CUBE_REQUEST => "Network::Protocol::PacketCubeRequest",
      CUBE_RESPONSE => "Network::Protocol::PacketCubeResponse"
    }

    def self.parse(msg)
      code = msg.unpack("c")[0]

      Object.const_get(CODE_TO_PACKET[code]).unpack(msg)
    end

    ############
    # PacketIn
    #
    #
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
    end

    ############
    # PacketCubeRequest
    #
    #
    class PacketCubeRequest
      DATA_FORMAT = "c"

      def initialize
        @code = Protocol::CUBE_REQUEST
      end

      def self.unpack(msg)
        data = msg.unpack(DATA_FORMAT)
        packet = self.new
        packet
      end

      def pack
        [@code].pack DATA_FORMAT
      end
    end

    ############
    # PacketCubeResponse
    #
    #
    class PacketCubeResponse
      DATA_FORMAT = "c d*"

      attr_accessor :vector

      def initialize
        @code = Protocol::CUBE_RESPONSE
      end

      def self.unpack(msg)
        data = msg.unpack(DATA_FORMAT)
        packet = self.new
        packet.vector = data[1..-1]
        packet
      end

      def pack
        data = [@code] + vector
        data.pack DATA_FORMAT
      end
    end
  end
end
