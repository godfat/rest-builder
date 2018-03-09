
require 'rest-builder/test'

describe RestBuilder::Middleware do
  describe '.has_payload?' do
    would 'be true when payload is not Payload::Unspecified' do
      expect(RestBuilder::Middleware).has_payload?({})
    end

    would 'be true when payload is not empty' do
      expect(RestBuilder::Middleware).has_payload?({'some' => 'thing'})
    end

    would 'be true when payload is Payload::Unspecified but has something' do
      expect(RestBuilder::Middleware).has_payload?(
        RestBuilder::Payload::Unspecified.new({'some' => 'thing'}))
    end
  end
end
