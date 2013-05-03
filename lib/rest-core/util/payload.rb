
# stolen and modified from rest-client

require 'rest-core/error'

require 'mime/types'

require 'stringio'
require 'tempfile'

module RestCore; end
module RestCore::Payload
  include RestCore
  module_function

  def generate payload
    if payload.respond_to?(:read)
      Streamed.new(payload)

    elsif payload.kind_of?(String)
      StreamedString.new(payload)

    elsif payload.kind_of?(Hash)
      if Middleware.contain_binary?(payload)
        Multipart.new(payload)

      else
        UrlEncoded.new(payload)
      end

    else
      raise Error.new("Payload should be either String, Hash, or" \
                      " responding to `read', but: #{payload.inspect}")
    end
  end

  class Streamed
    def initialize payload
      @io = payload
    end

    attr_reader  :io
    alias_method :to_io, :io

    def read bytes=nil
      io.read(bytes)
    end

    def headers
      {'Content-Length' => size.to_s}
    end

    def size
      if io.respond_to?(:size)
        io.size
      elsif io.respond_to?(:stat)
        io.stat.size
      else
        0
      end
    end

    def close  ; io.close unless closed?; end
    def closed?; io.closed?             ; end
  end

  class StreamedString < Streamed
    def initialize payload
      super(StringIO.new(payload))
    end
  end

  class UrlEncoded < StreamedString
    def initialize payload
      super(RestCore::Middleware.percent_encode(payload))
    end

    def headers
      super.merge('Content-Type' => 'application/x-www-form-urlencoded')
    end
  end

  class Multipart < Streamed
    EOL = "\r\n"

    def initialize payload
      super(Tempfile.new("rest-core.payload.#{boundary}"))

      io.binmode

      payload.each_with_index do |(k, v), i|
        if v.kind_of?(Array)
          v.each{ |vv| part(k, vv) }
        else
          part(k, v)
        end
      end
      io.write("--#{boundary}--#{EOL}")
      io.rewind
    end

    def part k, v
      io.write("--#{boundary}#{EOL}Content-Disposition: form-data")
      io.write("; name=\"#{k}\"") if k
      if v.respond_to?(:read)
        part_binary(k, v)
      else
        part_plantext(k, v)
      end
    end

    def part_plantext k, v
      io.write("#{EOL}#{EOL}#{v}#{EOL}")
    end

    def part_binary k, v
      if v.respond_to?(:original_filename)                   # Rails
        io.write("; filename=\"#{v.original_filename}\"#{EOL}")
      elsif v.respond_to?(:path)                             # files
        io.write("; filename=\"#{File.basename(v.path)}\"#{EOL}")
      else                                                   # io
        io.write("; filename=\"#{k}\"#{EOL}")
      end

      # supply your own content type for regular files, will you?
      if v.respond_to?(:content_type)                        # Rails
        io.write("Content-Type: #{v.content_type}#{EOL}#{EOL}")
      elsif v.respond_to?(:path) && type = mime_type(v.path) # files
        io.write("Content-Type: #{type}#{EOL}#{EOL}")
      else
        io.write(EOL)
      end

      while data = v.read(8192)
        io.write(data)
      end

      io.write(EOL)

    ensure
      v.close if v.respond_to?(:close)
    end

    def mime_type path
      mime = MIME::Types.type_for(path)
      mime.first && mime.first.content_type
    end

    def boundary
      @boundary ||= rand(1_000_000).to_s
    end

    def headers
      super.merge('Content-Type' =>
                    "multipart/form-data; boundary=#{boundary}")
    end

    def close
      io.close! unless io.closed?
    end
  end
end
