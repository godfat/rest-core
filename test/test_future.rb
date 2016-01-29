
require 'stringio'
require 'rest-core/test'

describe RC::Promise::Future do
  would 'fulfill the future' do
    promise = RC::Promise.new
    promise.fulfill(RC::RESPONSE_STATUS => 200,
                    RC::RESPONSE_HEADERS => {'A' => 'B'},
                    RC::RESPONSE_BODY => 'body',
                    RC::RESPONSE_SOCKET => StringIO.new,
                    RC::FAIL => [])

    promise.future_body    .should.eq 'body'
    promise.future_status  .should.eq 200
    promise.future_headers .should.eq('A' => 'B')
    promise.future_socket  .should.kind_of?(StringIO)
    promise.future_failures.should.eq []
    ([] + promise.future_failures).should.eq []
  end
end
