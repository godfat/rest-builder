
require 'thread'
require 'rest-builder/error'

module RestBuilder
  class EventSource < Struct.new(:client, :path, :query, :opts, :socket)
    READ_WAIT = 35

    def start
      self.mutex = Mutex.new
      self.condv = ConditionVariable.new
      @onopen      ||= nil
      @onmessage   ||= nil
      @onerror     ||= nil
      @onreconnect ||= nil
      @closed      ||= false
      reconnect
      self
    end

    def closed?
      !!(socket && socket.closed?) || @closed
    end

    def close
      socket && socket.close
    rescue IOError
    end

    def wait
      raise Error.new("Not yet started for: #{self}") unless mutex
      mutex.synchronize{ condv.wait(mutex) until closed? } unless closed?
      self
    end

    def onopen sock=nil, &cb
      if block_given?
        @onopen = cb
      else
        self.socket = sock # for you to track the socket
        @onopen.call(sock) if @onopen
        onmessage_for(sock)
      end
      self
    rescue Exception => e
      begin # close the socket since we're going to stop anyway
        sock.close # if we don't close it, client might wait forever
      rescue IOError
      end
      # let the client has a chance to handle this, and make signal
      onerror(e, sock)
    end

    def onmessage event=nil, data=nil, sock=nil, &cb
      if block_given?
        @onmessage = cb
      elsif @onmessage
        @onmessage.call(event, data, sock)
      end
      self
    end

    # would also be called upon closing, would always be called at least once
    def onerror error=nil, sock=nil, &cb
      if block_given?
        @onerror = cb
      else
        begin
          Promise.set_backtrace(error)
          @onerror.call(error, sock) if @onerror
          onreconnect(error, sock)
        rescue Exception
          mutex.synchronize do
            @closed = true
            condv.signal # so we can't be reconnecting, need to try to unblock
          end
          raise
        end
      end
      self
    end

    # would be called upon closing,
    # and would try to reconnect if a callback is set and return true
    def onreconnect error=nil, sock=nil, &cb
      if block_given?
        @onreconnect = cb
      elsif closed? && @onreconnect && @onreconnect.call(error, sock)
        reconnect
      else
        mutex.synchronize do
          @closed = true
          condv.signal # we could be closing, let's try to unblock it
        end
      end
      self
    end

    protected
    attr_accessor :mutex, :condv

    private
    # called in requesting thread after the request is done
    def onmessage_for sock
      while IO.select([sock], [], [], READ_WAIT)
        event = sock.readline("\n\n").split("\n").inject({}) do |r, i|
          k, v = i.split(': ', 2)
          r[k] = v
          r
        end
        onmessage(event['event'], event['data'], sock)
      end
      close_sock(sock)
      onerror(EOFError.new, sock)
    rescue IOError, SystemCallError => e
      close_sock(sock)
      onerror(e, sock)
    end

    def close_sock sock
      sock.close
    rescue IOError => e
      onerror(e, sock)
    end

    def reconnect
      o = {REQUEST_HEADERS => {'Accept' => 'text/event-stream'},
           HIJACK          => true}.merge(opts)
      client.get(path, query, o) do |sock|
        if sock.nil? || sock.kind_of?(Exception)
          onerror(sock)
        else
          onopen(sock)
        end
      end
    end
  end
end
