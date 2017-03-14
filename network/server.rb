require_relative 'socketd'
require 'pry'

cameras = {}

Network::Server.new(ARGV[0]).start do |connection, msg, sender|
  packet = Network::Protocol.parse msg

  if packet.is_a? Network::Protocol::PacketCamera
    cid = "#{sender[2]}_#{sender[1]}"
    cameras[cid] ||= Network::Protocol::PacketCameraUniq.new
    cameras[cid].id = cid
    cameras[cid].vector = packet.vector
  end

  pcks = []

  cameras.each do |k,v|
    unless k == cid
      pcks << v.pack
    end
  end

  connection.send pcks.join(Network::Protocol::SPLITSTR), Socket::MSG_DONTWAIT, sender[2], sender[1]
end
