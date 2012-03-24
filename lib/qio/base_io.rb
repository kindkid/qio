require 'thread'

module QIO

  # Classes that want to mimic IO can acqire much of its functionality simply
  # by including this module and over-riding the following methods:
  #
  #   close
  #   closed?
  #   eof?
  #   sysread(maxlen, outbuf=nil)
  #   sysseek(offset, whence=IO::SEEK_SET)
  #   syswrite(string)
  #
  # The following methds are not provided. If you know what you're doing, and
  # you know that you're going to need it, you may also over-ride:
  #
  #   autoclose=(bool)
  #   autoclose?
  #   close_on_exec=(bool)
  #   close_on_exec?
  #   close_read
  #   close_write
  #   fcntl(integer_cmd, arg)
  #   fileno
  #   flush
  #   fsync
  #   ioctl(integer_cmd, arg)
  #   pid
  #   reopen(other_io_or_path, mode_str=nil)
  #   stat
  #   sync
  #   sync=(bool)
  #   ungetbyte(string_or_integer)
  #   ungetc(string)
  #
  # You get all the following for free, but if that's not good enough for you,
  # and you're sure you can do better, you may over-ride:
  #
  #   <<(obj)
  #   advise(advice, offset=0, len=0)
  #   binmode #TODO!
  #   binmode? #TODO!
  #   bytes
  #   chars
  #   codepoints
  #   each
  #   each_byte
  #   each_char
  #   each_codepoint
  #   each_line
  #   eof
  #   external_encoding #TODO!
  #   fdatasync
  #   getbyte
  #   getc   #TODO!
  #   gets(sep=$/, limit=nil)
  #   internal_encoding #TODO!
  #   isatty
  #   lineno
  #   lineno=(lineno)
  #   lines(sep=$/, limit=nil)
  #   pos
  #   pos=(pos)
  #   print(*args)
  #   printf(format_string, *args)
  #   putc(obj)
  #   puts(*args)
  #   read(length=nil, buffer=nil)
  #   read_nonblock(maxlen, outbuf=nil)
  #   readbyte
  #   reachar
  #   readline(sep=$/, limit=nil)
  #   readlines(sep=$/, limit=nil)
  #   readpartial(maxlen, outbuf=nil)
  #   rewind
  #   seek(amount, whence=IO::SEEK_SET)
  #   set_encoding(ext_enc, int_enc=nil, opt=nil) #TODO!
  #   tell
  #   to_i  # if you defined fileno
  #   tty?
  #   write(string)
  #   write_nonblock(string)
  #
  module BaseIO

    # Implementation relies on: write
    def <<(obj)
      write(obj.to_s)
      self
    end

    # No-op
    def advise(advice, offset=0, len=0); end

    # NotImplementedError
    def autoclose=(bool)
      raise NotImplementedError
    end

    # NotImplementedError
    def autoclose?
      raise NotImplementedError
    end

    # TODO: Implement binmode.
    def binmode
    end

    # TODO: Implement: binmode?
    def binmode?
      true
    end

    # Implementation relies on: getbyte
    def bytes
      return to_enum :bytes unless block_given?
      while b = getbyte
        yield b
      end
    end
    alias :each_byte :bytes

    # Implementation relies on: getc
    def chars
      return to_enum :chars unless block_given?
      while c = getc
        yield c
      end
    end
    alias :each_char :chars

    # Over-ride me!
    def close
      raise NotImplementedError, "Subclass should over-ride!"
    end

    # NotImplementedError
    def close_on_exec=(bool)
      raise NotImplementedError
    end

    # NotImplementedError
    def close_on_exec?
      raise NotImplementedError
    end

    # NotImplementedError
    def close_read
      raise NotImplementedError
    end

    # NotImplementedError
    def close_write
      raise NotImplementedError
    end

    # Over-ride me!
    def closed?
      raise NotImplementedError, "Subclass should over-ride!"
    end

    # Implementation relies on: getc
    def codepoints
      return to_enum :codepoints unless block_given?
      while c = getc
        c.codepoints.each do |cp|
          yield cp
        end
      end
    end
    alias :each_codepoint :codepoints

    # Over-ride me!
    def eof?
      raise NotImplementedError, "Subclass should over-ride!"
    end
    alias :eof :eof?

    # TODO: Implement external_encoding
    def external_encoding
      raise NotImplementedError
    end

    # NotImplementedError
    def fcntl(integer_cmd, arg)
      raise NotImplementedError
    end

    # Implementation relies on: fsync
    def fdatasync
      fsync
    end

    # NotImplementedError
    def fileno
      raise NotImplementedError
    end
    alias :to_i :fileno

    # NotImplementedError
    def flush
      raise NotImplementedError
    end

    # NotImplementedError
    def fsync
      raise NotImplementedError
    end

    # Implementation relies on: read
    def getbyte
      read(1)
    end

    # TODO: Implement getc (probably need to know about encoding conversions first)
    def getc
      raise NotImplementedError
    end

    # Implementation relies on: getc
    # TODO: Maybe it should rely on getbyte instead, so we don't read too many bytes on accident.
    def gets(sep=$/, limit=nil)
      return nil if eof?
      if limit.nil? && sep.is_a?(Integer) #TODO: compare this logic with ::IO#getc
        limit = sep.to_i
        sep = $/
      end
      if !limit.nil? && limit < 0
        raise ArgumentError, ('negative limit %1d given' % limit)
      end
      sep = "\n\n" if sep == ""
      line = ""
      while (c = getc)
        line << c
        break if !sep.nil? && line.end_with?(sep)
        break if !limit.nil? && line.bytesize >= limit
      end
      if !limit.nil? && limit >= 0 && line.bytesize > limit
        leftovers = line.byteslice(limit .. -1) #TODO: what should we do with this?
        line = line.byteslice(0,limit)
      end
      $. = (lineno += 1)
      $_ = line
    end

    # TODO: Implement internal_encoding
    def internal_encoding
      raise NotImplementedError
    end

    # NotImplementedError
    def ioctl(integer_cmd, arg)
      raise NotImplementedError
    end

    # Always returns false
    def isatty
      false
    end
    alias :tty? :isatty

    # Implementation relies on gets to properly keep this up-to-date.
    def lineno
      @lineno || uninitialized!
    end

    def lineno=(lineno)
      @lineno = lineno
    end

    # Implementation relies on: gets
    def lines(sep=$/, limit=nil)
      return to_enum :lines unless block_given?
      while s = gets
        yield s
      end
    end
    alias :each :lines
    alias :each_line :lines

    # NotImplementedError
    def pid
      raise NotImplementedError
    end

    # Subclass is responsible for keeping pos up-to-date!
    def pos
      @pos || uninitialized!
    end
    alias :tell :pos

    # Subclass is responsible for keeping pos up-to-date!
    def pos=(pos)
      @pos = pos
    end

    # Implementation relies on write.
    def print(*args)
      args = [$_] if args.size == 0
      first_one = true
      args.each do |obj|
        write(obj.to_s)
        write($,) unless first_one || $,.nil?
        first_one = false
      end
      write($\) unless $\.nil?
      nil
    end

    # Implementation relies on print.
    def printf(format_string, *args)
      print(Kernel.sprintf(format_string, *args))
    end

    # Implementation relies on write.
    def putc(obj)
      if obj.is_a?(Numeric)
        write((obj.to_i & 0xff).chr)
      else
        write(obj.to_s.byteslice(0))
      end
    end

    def puts(*args)
      if args.size == 0
        write("\n")
      else
        args.flatten.each do |line|
          line = line.to_s
          write(line)
          write("\n") unless line.end_with?("\n")
        end
      end
      nil
    end

    def read(length=nil, buffer=nil)
      if !length.nil? && length < 0
        raise ArgumentError, ('negative length %1d given' % length)
      end

      buffer = buffer.nil? ? "" : buffer.replace("")
      if length.nil?
        begin
          buffer << readpartial until eof?
        rescue EOFError
        end
        # TODO: Apply encoding conversion to buffer.
        buffer
      elsif length == 0
        buffer
      else
        begin
          while buffer.bytesize < length && !eof?
            buffer << readpartial(length - buffer.bytesize)
            # TODO: Code Review - result should be ASCII-8BIT. Is it?
          end
        rescue EOFError
        end
        buffer.empty? ? nil : buffer
      end
    end

    def read_nonblock(maxlen, outbuf=nil)
      nonblock_readable do
        sysread(maxlen, outbuff)
      end
    end

    # Implementation relies on getbyte
    def readbyte
      getbyte || raise(EOFError)
    end

    # Implementation relies on: getc
    def readchar
      getc || raise(EOFError)
    end

    # Implementation relies on: gets
    def readline(sep=$/, limit=nil)
      gets(sep, limit) || raise(EOFError)
    end

    # Implementation relies on: gets
    def readlines(sep=$/, limit=nil)
      result = []
      loop do
        if (line = gets(sep, limit))
          break
        else
          result << line
        end
      end
      result
    end

    # Implementation relies on: read_nonblock
    def readpartial(maxlen, outbuf=nil)
      read_nonblock(maxlen, outbuf)
    rescue IO::WaitReadable
      block_until_readable
      retry
    end

    # NotImplementedError
    def reopen(other_io_or_path, mode_str=nil)
      raise NotImplementedError
    end

    # Implementation relies on: seek
    def rewind
      seek(0)
    end

    # Implementation relies on: sysseek
    def seek(amount, whence=IO::SEEK_SET)
      sysseek(amount, whence)
    end

    # TODO: Implement set_encoding
    def set_encoding(ext_enc, int_enc=nil, opt=nil)
      raise NotImplementedError
    end

    # NotImplementedError
    def stat
      raise NotImplementedError
    end

    # NotImplementedError
    def sync
      raise NotImplementedError
    end

    # NotImplementedError
    def sync=(bool)
      raise NotImplementedError
    end

    # Over-ride me!
    # Remember to count *bytes*, not chars.
    # Remember to update pos.
    # Remember to use consume_readable to wrap the atomic part of your update.
    def sysread(maxlen, outbuf=nil)
      raise NotImplementedError
    end

    # Over-ride me!
    # Remember to count *bytes*, not chars.
    # Remember to update pos.
    def sysseek(offset, whence=IO::SEEK_SET)
      raise NotImplementedError # TODO: provide best-effort implementation for sysseek
    end

    # Over-ride me!
    # Remember to count *bytes*, not chars.
    # Remember to update pos.
    # Remember to use consume_writable to wrap the atomic part of your update.
    def syswrite(string)
      raise NotImplementedError
    end

    # NotImplementedError
    def ungetbyte(string_or_integer)
      raise NotImplementedError
    end

    # NotImplementedError
    def ungetc(string)
      raise NotImplementedError
    end

    # Implementation relies on: write_nonblock
    def write(string)
      written = 0
      length = string.bytesize
      while written < length
        begin
          written += write_nonblock(string.byteslice(written, length - written))
        rescue IO::WaitWritable, Errno::EINTR
          block_until_writable
          retry
        end
      end
      written
    end

    # Implementation relies on: syswrite
    def write_nonblock(string)
      nonblock_writable do
        syswrite(string)
      end
    end

    protected

    # Subclass should call super in initialize
    def initialize(*args, &callback)
      super(*args, &callback)
      @pos = 0
      @lineno = 0
      @mutex = Mutex.new
      @readable_resource = ConditionVariable.new
      @writable_resource = ConditionVariable.new
      @nonblock_readable = false
      @nonblock_writable = false
    end

    # Subclass should call me as appropriate. I'll take care of waking threads.
    # Your callback must:
    #  * Be quick, you're inside a critical section!
    #  * Return true if it's safe to do a non-blocking read, false otherwise.
    def consume_readable(&callback)
      synchronize do
        bool = callback.call
        if @nonblock_readable != bool
          @nonblock_readable = bool
          readable_resource.signal
        end
      end
    end

    # Subclass should call me as appropriate. I'll take care of waking threads.
    # Your callback must:
    #  * Be quick, you're inside a critical section!
    #  * Return true if it's safe to do a non-blocking write, false otherwise.
    def consume_writable(&callback)
      synchronize do
        bool = callback.call
        if @nonblock_writable != bool
          @nonblock_writable = bool
          writable_resource.signal
        end
      end
    end

    alias :provide_readable :consume_readable
    alias :provide_writable :consume_writable

    private

    def uninitialized!
      raise "Subclass did not call super in its initialize method!"
    end

    def mutex
      @mutex || uninitialized!
    end

    def readable_resource
      @readable_resource || uninitialized!
    end

    def writable_resource
      @writable_resource || uninitialized!
    end

    # Don't call this unless you know what you're doing!
    def synchronize
      mutex.synchronize do
        yield
      end
    end

    def block_until_readable(&callback)
      loop do
        synchronize do
          return if @nonblock_readable
          readable_resource.wait(mutex)
        end
      end
    end

    def block_until_writable
      loop do
        synchronize do
          return if @nonblock_writable
          writable_resource.wait(mutex)
        end
      end
    end

    def nonblock_readable(&callback)
      synchronize do
        if @nonblock_readable
          callback.call
        else
          raise(IO::WaitReadable, "read would block")
        end
      end
    end

    def nonblock_writable(&callback)
      synchronize do
        if @nonblock_writable
          callback.call
        else
          raise(IO::WaitWritable, "write would block")
        end
      end
    end
  end
end