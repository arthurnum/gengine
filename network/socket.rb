require 'socket'

require_relative 'protocol'

module Network
  class Client
    def initialize(addr, obj_link)
      @conn = UDPSocket.new
      @packet = Network::Protocol::PacketCubeRequest.new
      @addr = addr
      @obj_link = obj_link
      @dest = Socket.sockaddr_in(45000, addr)
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
      @conn.send @packet.pack, Socket::MSG_DONTWAIT, @dest
    end
  end
end
