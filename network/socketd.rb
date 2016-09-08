require 'socket'
require 'pry'

server = UDPSocket.new
server.bind('127.0.0.1', 45000)

def build_response_string
  header = "Gengine daemon protocol v0.01"
  code = rand(10)
  codef = rand(10) * 2.43

  data_format = "A#{header.bytesize} L G"
  parse_format = "@32 #{data_format}"
  pack_format = "A32 #{data_format}"

  [parse_format, header, code, codef].pack pack_format
end

begin
  msg, sender = server.recvfrom_nonblock(10)
  puts "#{sender[3]}:#{sender[1]} => #{msg}"
  server.send build_response_string, 0, sender[3], sender[1]
rescue IO::WaitReadable => ex
  retry
end while true
