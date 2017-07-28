module Network
  module Protocol
    # Gengine daemon protocol
    VERSION = '0.01'.freeze
    HEADER = "GDP #{VERSION}".freeze

    SPLITSTR = 'PCK'

    IN             = 1
    CUBE_REQUEST   = 2
    CUBE_RESPONSE  = 3
    CAMERA         = 4
    CAMERA_UNIQ    = 5
    USER_LOG_IN    = 6
    USER_LOG_IN_OK = 7

    CODE_TO_PACKET = {
      IN              => "Network::Protocol::PacketIn",
      CUBE_REQUEST    => "Network::Protocol::PacketCubeRequest",
      CUBE_RESPONSE   => "Network::Protocol::PacketCubeResponse",
      CAMERA          => "Network::Protocol::PacketCamera",
      CAMERA_UNIQ     => "Network::Protocol::PacketCameraUniq",
      USER_LOG_IN     => "Network::Protocol::PacketUserLogIn",
      USER_LOG_IN_OK  => "Network::Protocol::PacketUserLogInOK"
    }

    def self.parse(msg)
      code = msg.unpack("c")[0]

      return unless code

      Object.const_get(CODE_TO_PACKET[code]).unpack(msg)
    end

    module Base
      def user_log_in_ok?; false; end
    end

    ############
    # PacketIn
    #
    #
    class PacketIn
      include Base

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
      include Base

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
      include Base

      DATA_FORMAT = "c d*"

      attr_accessor :vector

      def initialize
        @code = Protocol::CUBE_RESPONSE
        @vector = [0.0, 0.0, 0.0]
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

    ############
    # PacketCamera
    #
    #
    class PacketCamera
      include Base

      DATA_FORMAT = "c d*"

      attr_accessor :vector

      def initialize
        @code = Protocol::CAMERA
        @vector = [0.0, 0.0, 0.0]
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

    ############
    # PacketCameraUniq
    #
    #
    class PacketCameraUniq
      include Base

      DATA_FORMAT = "c A24 d*"

      attr_accessor :id, :vector

      def initialize
        @code = Protocol::CAMERA_UNIQ
      end

      def self.unpack(msg)
        data = msg.unpack(DATA_FORMAT)
        packet = self.new
        packet.id = data[1]
        packet.vector = data[2..-1]
        packet
      end

      def pack
        data = [@code]
        data << "%-24s" % @id
        data << @vector
        data.flatten.pack DATA_FORMAT
      end
    end

    ############
    # PacketUserLogIn
    #
    #
    class PacketUserLogIn
      include Base

      DATA_FORMAT = "c A32"

      attr_accessor :player_name

      def initialize
        @code = Protocol::USER_LOG_IN
      end

      def self.unpack(msg)
        data = msg.unpack(DATA_FORMAT)
        packet = self.new
        packet.player_name = data[1]
        packet
      end

      def pack
        data = [@code]
        data << "%-32s" % player_name
        data.flatten.pack DATA_FORMAT
      end
    end

    ############
    # PacketUserLogInOK
    #
    #
    class PacketUserLogInOK
      include Base

      DATA_FORMAT = "c"

      def initialize
        @code = Protocol::USER_LOG_IN_OK
      end

      def self.unpack(msg)
        data = msg.unpack(DATA_FORMAT)
        packet = self.new
        packet
      end

      def pack
        data = [@code]
        data.flatten.pack DATA_FORMAT
      end

      def user_log_in_ok?
        true
      end
    end
  end
end
