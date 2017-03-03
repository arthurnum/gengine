require 'socket'

require_relative 'protocol'

module Network
  class Client
    def initialize(addr, obj_link)
      @conn = UDPSocket.new
      @packet = Network::Protocol::PacketCubeRequest.new
      @addr = addr
      @obj_link = obj_link
    end

    def read
      msg, sender = @conn.recvfrom_nonblock(128)

      rp = Network::Protocol.parse msg

      if rp.is_a? Network::Protocol::PacketCubeResponse
        @obj_link.position = Vector.elements(rp.vector)
      end
    rescue IO::WaitReadable => ex
      #no block
    end

    def write
      @conn.send @packet.pack, Socket::MSG_DONTWAIT, @addr, 45000
    end
  end
end
