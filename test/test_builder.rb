
require 'rest-builder/test'

describe RestBuilder::Builder do
  would 'default client app is a kind of RestBuilder::Engine' do
    RestBuilder::Builder.client.new.app.should.kind_of? RestBuilder::Engine
  end

  would 'default        app is a kind of RestBuilder::Engine' do
    RestBuilder::Builder.new.to_app.should.kind_of? RestBuilder::Engine
  end

  would 'switch default_engine to RestBuilder::Dry a' do
    builder = Class.new(RestBuilder::Builder)
    builder.default_engine = RestBuilder::Dry
    builder.new.to_app.class.should.eq RestBuilder::Dry
  end

  would 'switch default_engine to RestBuilder::Dry b' do
    builder = RestBuilder::Builder.dup
    builder.default_engine = RestBuilder::Dry
    builder.client.new.app.class.should.eq RestBuilder::Dry
  end

  would 'accept middleware without a member' do
    RestBuilder::Builder.client{
      use Class.new.send(:include, RestBuilder::Middleware)
    }.members.should.eq [:config_engine]
  end

  would 'not have duplicated fields' do
    middleware = Class.new do
      def self.members; [:value]; end
      include RestBuilder::Middleware
    end
    client = RestBuilder::Builder.client(:value){ use middleware }.new
    client.value = 10
    client.value.should.eq 10
  end

  would 'have the same pool for the same client' do
    client = RestBuilder::Builder.client
    client.thread_pool.object_id.should.eq client.thread_pool.object_id
  end
end
