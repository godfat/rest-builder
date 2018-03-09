
require 'rest-builder/test'

describe RestBuilder::Middleware do
  describe '.unspecified_payload?' do
    would 'be false when payload is not Payload::Unspecified' do
      expect(RestBuilder::Middleware).
        not.unspecified_payload?({})
    end

    would 'be false when payload is not empty' do
      expect(RestBuilder::Middleware).
        not.unspecified_payload?({'some' => 'thing'})
    end

    would 'be false when payload is Payload::Unspecified but has something' do
      payload = RestBuilder::Payload::Unspecified.new
      payload['some'] = 'thing'

      expect(RestBuilder::Middleware).
        not.unspecified_payload?(payload)
    end

    would 'be true when payload is Payload::Unspecified and empty' do
      expect(RestBuilder::Middleware).
        unspecified_payload?(RestBuilder::Payload::Unspecified.new)
    end

    describe '.has_payload?' do
      after do
        Muack.verify
      end

      would 'just pass to unspecified_payload?' do
        mock(RestBuilder::Middleware).unspecified_payload?({})

        expect(RestBuilder::Middleware).
          has_payload?(RestBuilder::REQUEST_PAYLOAD => {})
      end
    end

    describe '.contain_binary?' do
      would 'give false for unspecified payload' do
        expect(RestBuilder::Middleware).
          not.contain_binary?(RestBuilder::Payload::Unspecified.new)
      end

      would 'give true for IO' do
        rd, _ = IO.pipe

        expect(RestBuilder::Middleware).contain_binary?(rd)
      end

      would 'give true when one of the payload is IO' do
        rd, _ = IO.pipe

        expect(RestBuilder::Middleware).contain_binary?(['', rd])
        expect(RestBuilder::Middleware).contain_binary?('key' => rd)
      end

      would 'give false when none of payload is IO' do
        expect(RestBuilder::Middleware).not.contain_binary?([''])
        expect(RestBuilder::Middleware).not.contain_binary?('key' => 'value')
      end
    end

    describe '.string_keys' do
      would 'convert hash keys to strings' do
        expect(RestBuilder::Middleware.string_keys(:a => 'b')).eq 'a' => 'b'
      end

      would 'convert hash keys to strings recursively for query, payload, headers' do
        expect(RestBuilder::Middleware.string_keys(
          RestBuilder::REQUEST_QUERY => {:a => 'b'},
          RestBuilder::REQUEST_PAYLOAD => {:c => 'd'},
          RestBuilder::REQUEST_HEADERS => {:e => 'f'})).
          eq RestBuilder::REQUEST_QUERY => {'a' => 'b'},
             RestBuilder::REQUEST_PAYLOAD => {'c' => 'd'},
             RestBuilder::REQUEST_HEADERS => {'e' => 'f'}
      end

      would 'leave Payload::Unspecified alone' do
        payload = RestBuilder::Payload::Unspecified.new

        expect(RestBuilder::Middleware.string_keys(:a => payload)).
          eq 'a' => payload
      end
    end
  end
end
