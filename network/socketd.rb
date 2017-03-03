require 'socket'

require_relative 'protocol'

module Network
  class Server
    SERVER_PORT = 45000

    def initialize(addr)
      @connection = UDPSocket.new
      @connection.bind(addr, SERVER_PORT)
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
      @queue.push @connection.recvfrom_nonblock(128) if @queue.size < 10
    rescue IO::WaitReadable => ex
      # no block
    end
  end
end
