require_relative 'socketd'
require 'pry'

Network::Server.new(ARGV[0]).start do |connection, msg, sender|
  packet = Network::Protocol.parse msg

  if packet.is_a? Network::Protocol::PacketCubeRequest
    rp = Network::Protocol::PacketCubeResponse.new
    rp.vector = [rand, rand, rand]
    connection.send rp.pack, Socket::MSG_DONTWAIT, sender[2], sender[1]
  end

end.join
