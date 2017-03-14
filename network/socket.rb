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

      msg.split(Network::Protocol::SPLITSTR).each do |pck|

        rp = Network::Protocol.parse pck

        if rp.is_a? Network::Protocol::PacketCameraUniq
          @obj_link[rp.id] ||= Drawing::Object::Cube.new(0.0, 0.0, 0.0, 0.5)
          @obj_link[rp.id].position = Vector.elements(rp.vector)
        end

      end

    rescue IO::WaitReadable => ex
      #no block
    end

    def write(packets)
      packets.each do |packet|
        @conn.send packet.pack, Socket::MSG_DONTWAIT, @dest
      end
    end
  end
end
