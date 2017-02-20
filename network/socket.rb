require 'socket'
require 'pry'

require_relative 'protocol'

conn = UDPSocket.new

listener = Thread.new do
  begin
    msg = conn.recvfrom_nonblock(128)
    puts msg
  rescue IO::WaitReadable => ex
    retry
  end while true
end

packet = Network::Protocol::PacketIn.new
packet.username = "arthurnum"

begin
conn.send packet.pack, Socket::MSG_DONTWAIT, ARGV[0], 45000
sleep 1
end while true
