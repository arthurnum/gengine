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
      worker_thr = Thread.new do
        begin
          msg, sender = @connection.recvfrom_nonblock(128)
          yield @connection, msg, sender
        rescue IO::WaitReadable => ex
          # save CPU time
          sleep 0.1
        end while true
      end.join
    end

  end
end
