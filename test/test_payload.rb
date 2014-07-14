
require 'rest-core/test'

describe RC::Payload do
  describe 'A regular Payload' do
    would 'use standard enctype as default content-type' do
      RC::Payload::UrlEncoded.new({}).headers['Content-Type'].
        should.eq 'application/x-www-form-urlencoded'
    end

    would 'form properly encoded params' do
      RC::Payload::UrlEncoded.new(:foo => 'bar').read.
        should.eq 'foo=bar'
      RC::Payload::UrlEncoded.new(:foo => 'bar', :baz => 'qux').read.
        should.eq 'baz=qux&foo=bar'
    end

    would 'escape parameters' do
      RC::Payload::UrlEncoded.new('foo ' => 'bar').read.
        should.eq 'foo%20=bar'
    end

    would 'properly handle arrays as repeated parameters' do
      RC::Payload::UrlEncoded.new(:foo => ['bar']).read.
        should.eq 'foo=bar'
      RC::Payload::UrlEncoded.new(:foo => ['bar', 'baz']).read.
        should.eq 'foo=bar&foo=baz'
    end

    would 'not close if stream already closed' do
      p = RC::Payload::UrlEncoded.new('foo ' => 'bar')
      p.close
      2.times{ p.close.should.eq nil }
    end
  end

  describe 'A multipart Payload' do
    would 'use standard enctype as default content-type' do
      p = RC::Payload::Multipart.new({})
      stub(p).boundary{123}
      p.headers['Content-Type'].should.eq 'multipart/form-data; boundary=123'
    end

    would 'not error on close if stream already closed' do
      p = RC::Payload::Multipart.new(:file => File.open(__FILE__))
      p.close
      2.times{ p.close.should.eq nil }
    end

    would 'form properly separated multipart data' do
      p = RC::Payload::Multipart.new(:bar => 'baz', :foo => 'bar')
      p.read.should.eq <<-EOS
--#{p.boundary}\r
Content-Disposition: form-data; name="bar"\r
\r
baz\r
--#{p.boundary}\r
Content-Disposition: form-data; name="foo"\r
\r
bar\r
--#{p.boundary}--\r
      EOS
    end

    would 'form multiple files with the same name' do
      with_img do |f, n|
        with_img do |ff, nn|
          p = RC::Payload::Multipart.new(:foo => [f, ff])
          p.read.should.eq <<-EOS
--#{p.boundary}\r
Content-Disposition: form-data; name="foo"; filename="#{n}"\r
Content-Type: image/jpeg\r
\r
#{'a'*10}\r
--#{p.boundary}\r
Content-Disposition: form-data; name="foo"; filename="#{nn}"\r
Content-Type: image/jpeg\r
\r
#{'a'*10}\r
--#{p.boundary}--\r
          EOS
        end
      end
    end

    would 'not escape parameters names' do
      p = RC::Payload::Multipart.new('bar ' => 'baz')
      p.read.should.eq <<-EOS
--#{p.boundary}\r
Content-Disposition: form-data; name="bar "\r
\r
baz\r
--#{p.boundary}--\r
      EOS
    end

    would 'form properly separated multipart data' do
      with_img do |f, n|
        p = RC::Payload::Multipart.new(:foo => f)
        p.read.should.eq <<-EOS
--#{p.boundary}\r
Content-Disposition: form-data; name="foo"; filename="#{n}"\r
Content-Type: image/jpeg\r
\r
#{File.read(f.path)}\r
--#{p.boundary}--\r
        EOS
      end
    end

    would "ignore the name attribute when it's not set" do
      with_img do |f, n|
        p = RC::Payload::Multipart.new(nil => f)
        p.read.should.eq <<-EOS
--#{p.boundary}\r
Content-Disposition: form-data; filename="#{n}"\r
Content-Type: image/jpeg\r
\r
#{File.read(f.path)}\r
--#{p.boundary}--\r
        EOS
      end
    end

    would 'detect optional (original) content type and filename' do
      File.open(__FILE__) do |f|
        def f.content_type     ; 'image/jpeg'; end
        def f.original_filename; 'foo.txt'   ; end
        p = RC::Payload::Multipart.new(:foo => f)
        p.read.should.eq <<-EOS
--#{p.boundary}\r
Content-Disposition: form-data; name="foo"; filename="foo.txt"\r
Content-Type: image/jpeg\r
\r
#{File.read(f.path)}\r
--#{p.boundary}--\r
        EOS
      end
    end
  end

  describe 'streamed payloads' do
    would 'properly determine the size of file payloads' do
      File.open(__FILE__) do |f|
        p = RC::Payload.generate(f)
        p.size.should.eq f.stat.size
      end
    end

    would 'properly determine the size of other kinds of payloads' do
      s = StringIO.new('foo')
      p = RC::Payload.generate(s)
      p.size.should.eq 3

      begin
        f = Tempfile.new('rest-core')
        f.write('foo bar')
        f.rewind

        p = RC::Payload.generate(f)
        p.size.should.eq 7
      ensure
        f.close!
      end
    end
  end

  describe 'Payload generation' do
    would 'recognize standard urlencoded params' do
      RC::Payload.generate('foo' => 'bar').should.
        kind_of?(RC::Payload::UrlEncoded)
    end

    would 'recognize multipart params' do
      File.open(__FILE__) do |f|
        RC::Payload.generate('foo' => f).should.
          kind_of?(RC::Payload::Multipart)
      end
    end

    would 'return data if none of the above' do
      RC::Payload.generate('data').should.
        kind_of?(RC::Payload::StreamedString)
    end

    would 'recognize nested multipart payloads in arrays' do
      File.open(__FILE__) do |f|
        RC::Payload.generate('foo' => [f]).should.
          kind_of?(RC::Payload::Multipart)
      end
    end

    would 'recognize file payloads that can be streamed' do
      File.open(__FILE__) do |f|
        RC::Payload.generate(f).should.kind_of?(RC::Payload::Streamed)
      end
    end

    would 'recognize other payloads that can be streamed' do
      RC::Payload.generate(StringIO.new('foo')).should.
        kind_of?(RC::Payload::Streamed)
    end
  end
end
