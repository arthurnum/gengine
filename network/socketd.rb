require 'socket'
require 'pry'

require_relative 'protocol'

module Network
  class Server
    SERVER_PORT = 45000

    def initialize
      @connection = UDPSocket.new
      @connection.bind(ARGV[0], SERVER_PORT)
      @queue = []
    end

    def start
      listener_thr = Thread.new { loop do listen end }

      worker_thr = Thread.new do
        begin
          next if @queue.empty?

          msg, sender = @queue.shift
          yield @connection, msg, sender
        end while true
      end
    end

    private

    def listen
      @queue.push @connection.recvfrom_nonblock(1024)
    rescue IO::WaitReadable => ex
      # no block
    end
  end
end

Network::Server.new.start do |connection, msg, sender|
  packet = Network::Protocol.parse msg
  puts packet.username
  puts sender
  connection.send "hello", Socket::MSG_DONTWAIT, sender[2], sender[1]
end

loop do end
