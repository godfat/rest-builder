
require 'rest-builder/test'

describe RestBuilder::Identity do
  would 'respond basic status, body, and headers' do
    env = {RestBuilder::REQUEST_PATH => '/path'}

    RestBuilder::Identity.new.call(env) do |result|
      expect(result).eq(env)
    end
  end
end
