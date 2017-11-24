
require 'rest-builder/test'

describe RestBuilder::Dry do
  would 'respond basic status, body, and headers' do
    env = {RestBuilder::REQUEST_PATH => '/path'}
    res = {RestBuilder::RESPONSE_STATUS => 200,
           RestBuilder::RESPONSE_HEADERS => {},
           RestBuilder::RESPONSE_BODY => ''}

    RestBuilder::Dry.new.call(env) do |result|
      expect(result).eq(env.merge(res))
    end
  end
end
