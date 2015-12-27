
require 'rest-core/test'

describe RC::DalliExtension do
  after do
    Muack.verify
  end

  def engine env
    yield(env.merge(RC::RESPONSE_STATUS => 200,
                    RC::RESPONSE_HEADERS => {'A' => 'B'},
                    RC::RESPONSE_BODY => 'ok'))
  end

  def call dalli, opts={}, &block
    dalli.extend(RC::DalliExtension)
    RC::Cache.new(method(:engine), dalli, 10).
      call({RC::REQUEST_METHOD => :get,
            RC::REQUEST_HEADERS => {}}.merge(opts),
           &lambda{|_|_})[RC::RESPONSE_BODY]
  end

  would 'set and get' do
    dalli = Object.new
    mock(dalli).set(is_a(String), nil) do |key, value|
      mock(dalli).get(key){ "200\nA: B\n\n\nok" }
    end

    expect(call(dalli, 'cache.update' => true)).eq 'ok'
  end

  would 'store' do
    dalli = Object.new
    mock(dalli).get(is_a(String)) do |key|
      mock(dalli).set(key, "200\nA: B\n\n\nok", 10){}
      nil
    end

    expect(call(dalli)).eq 'ok'
  end
end
