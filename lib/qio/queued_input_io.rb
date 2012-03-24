module QIO
  class QueuedInputIO
    include BaseIO
    def initialize
      super
      @deque = [] #TODO: Consider using a real deque.
      @eof = false
      @closed = false
      @queued_eof = false
    end

    def close
      assert_open
      synchronize do
        @closed = true
        @deque.clear
        @deque = nil
      end
    end

    def closed?
      @closed
    end

    def eof?
      assert_open
      @eof ||= (@queued_eof && @deque.length <= 1)
    end

    def sysread(maxlen, outbuf=nil)
      q = @deque
      raise EOFError if eof?
      outbuf ||= ""
      consume_readable do
        raise EOFError if eof?
        data = @deque.shift
        raise SystemCallError if data.nil? || data.empty?
        if data.bytesize <= maxlen
          outbuf.replace(data)
          pos += outbuf.bytesize
        else
          outbuf.replace(data.byteslice(0, maxlen))
          @deque.unshift(data.byteslice(maxlen .. -1))
          pos += maxlen
        end
        @deque.any?
      end
      outbuf
    end

    def sysseek(offset, whence=IO::SEEK_SET)
      # TODO: Implement (best-effort) sysseek
    end

    def add_input(string)
      raise(ArgumentError, 'input must be a string') unless string.is_a?(String)
      assert_open
      assert_accepting_input
      return self if string.empty?
      provide_readable do
        assert_open
        assert_accepting_input
        @deque.push(string)
        true
      end
      self
    end

    def end_input!
      return self if @queued_eof
      provide_readable do
        unless @queued_eof
          @deque.push(:eof)
          @queued_eof = true
        end
        true
      end
      self
    end

    private

    def assert_open
      raise(IOError, "stream is closed!") if @closed
    end

    def assert_accepting_input
      raise(IOError, "stream was ended!") if @queued_eof
    end
  end
end
