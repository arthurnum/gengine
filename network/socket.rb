require 'socket'
require 'pry'

conn = UDPSocket.new

listener = Thread.new do
  begin
    msg = conn.recvfrom_nonblock(128)
    unpack_format = msg[0].unpack("A32")[0]

    header, code, codef = msg[0].unpack unpack_format

    puts header
    puts code
    puts codef
  rescue IO::WaitReadable => ex
    retry
  end while true
end

begin
conn.send "hello", Socket::MSG_DONTWAIT, '127.0.0.1', 45000
sleep 3
end while true
