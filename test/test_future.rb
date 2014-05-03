
require 'stringio'
require 'rest-core/test'

describe RC::Promise::Future do
  should 'fulfill the future' do
    promise = RC::Promise.new(RC::FAIL => [])
    promise.fulfill('body', 200, {'A' => 'B'}, StringIO.new)

    promise.future_body    .should.eq 'body'
    promise.future_status  .should.eq 200
    promise.future_headers .should.eq('A' => 'B')
    promise.future_socket  .should.kind_of(StringIO)
    promise.future_failures.should.eq []
  end
end
