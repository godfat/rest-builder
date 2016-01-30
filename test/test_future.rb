
require 'stringio'
require 'rest-builder/test'

describe RestBuilder::Promise::Future do
  would 'fulfill the future' do
    promise = RestBuilder::Promise.new
    promise.fulfill(RestBuilder::RESPONSE_STATUS => 200,
                    RestBuilder::RESPONSE_HEADERS => {'A' => 'B'},
                    RestBuilder::RESPONSE_BODY => 'body',
                    RestBuilder::RESPONSE_SOCKET => StringIO.new,
                    RestBuilder::FAIL => [])

    promise.future_body    .should.eq 'body'
    promise.future_status  .should.eq 200
    promise.future_headers .should.eq('A' => 'B')
    promise.future_socket  .should.kind_of?(StringIO)
    promise.future_failures.should.eq []
    ([] + promise.future_failures).should.eq []
  end
end
