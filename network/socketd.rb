require 'socket'
require 'pry'

require_relative 'protocol'

module Network
  class Server
    SERVER_PORT = 45000

    def initialize
      @connection = UDPSocket.new
      @connection.bind('127.0.0.1', SERVER_PORT)
      @queue = []
    end

    def start
      listener_thr = Thread.new { loop do listen end }

      worker_thr = Thread.new do
        begin
          next if @queue.empty?

          yield @queue.shift
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

Network::Server.new.start do |msg, sender|
  packet = Network::Protocol.parse msg
  puts packet.info
end

loop do end
