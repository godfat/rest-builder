
require 'rest-builder/test'

describe RestBuilder::Client do
  after do
    WebMock.reset!
    Muack.verify
  end

  url = 'http://example.com/'
  simple = RestBuilder::Builder.client

  would 'do simple request' do
    c = simple.new
    [:get, :post, :delete, :put, :patch].each do |method|
      stub_request(method, url).to_return(:body => '[]')
      c.send(method, url).should.eq '[]'
    end

    stub_request(:head   , url).to_return(:headers => {'A' => 'B'})
    c.   head(url).should.eq('A' => 'B')

    stub_request(:options, url).to_return(:headers => {'A' => 'B'})
    c.options(url).should.eq('A' => 'B')
  end

  would 'call the callback' do
    [:get, :post, :delete, :put, :patch].each do |method|
      stub_request(method, url).to_return(:body => '123')
      (client = simple.new).send(method, url){ |res|
        res.should.eq '123' }.should.eq client
      client.wait
    end

    stub_request(:head, url).to_return(:headers => {'A' => 'B'})
    (client = simple.new).head(url){ |res|
      res.should.eq({'A' => 'B'})
    }.should.eq client
    client.wait

    stub_request(:options, url).to_return(:headers => {'A' => 'B'})
    (client = simple.new).options(url){ |res|
      res.should.eq('A' => 'B')
    }.should.eq client
    client.wait
  end

  would 'wait for all the requests' do
    t, i, m = 5, 0, Mutex.new
    stub_request(:get, url).to_return do
      m.synchronize{ i += 1 }
      Thread.pass
      {}
    end

    client = RestBuilder::Builder.client
    t.times{ client.new.get(url) }
    client.wait
    client.promises.should.empty?
    i.should.eq t
  end

  would 'wait for callback' do
    rd, wr = IO.pipe
    called = false
    stub_request(:get, url).to_return(:body => 'nnf')
    client = simple.new.get(url) do |nnf|
      wr.puts
      sleep 0.001 # make sure our callback is slow enough,
                  # so that if `wait` is not waiting for the callback,
                  # it would leave before the callback is completely done.
                  # without sleeping, the callback is very likely to be
                  # done first than `wait` anyway. raising the sleeping time
                  # would make this test more reliable...
      called = true
      nil # test against returning nil, so that Promise#response is not set
    end
    rd.gets
    client.wait
    called.should.eq true
  end

  would 'cleanup promises' do
    stub_request(:get, url).to_return(:body => 'nnf')
    5.times{ simple.new.get(url) }
    Thread.pass
    GC.start # can only force GC run on MRI, so we mock for jruby and rubinius
    stub(any_instance_of(WeakRef)).weakref_alive?{false}
    simple.new.get(url)
    simple.promises.size.should.lt 6
    simple.shutdown
    simple.promises.should.empty?
  end

  would 'have correct to_i' do
    stub_request(:get, url).to_return(:body => '123')
    simple.new.get(url).to_i.should.eq 123
  end

  would 'use defaults' do
    client = RestBuilder::Builder.client do
      use Class.new{
        def self.members; [:timeout]; end
        include RestBuilder::Middleware
      }, 4
    end
    c = client.new
    c.timeout.should.eq 4 # default goes to middleware
    client.extend(Module.new do
      def default_timeout
        3
      end
    end)
    c.timeout.should.eq 4 # default is cached, so it stays the same
    c.timeout = nil       # clear cache
    c.timeout.should.eq 3 # now default goes to module default
    class << client
      def default_timeout # module defaults could be overriden
        super - 1
      end
    end
    c.timeout = nil
    c.timeout.should.eq 2 # so it goes to class default
    c.timeout = 1         # setup instance level value
    c.build_env(                )['timeout'].should.eq 1 # pick instance var
    c.build_env({'timeout' => 0})['timeout'].should.eq 0 # per-request var
    c.timeout.should.eq 1 # won't affect underlying instance var
    c.timeout = nil
    c.timeout.should.eq 2 # goes back to class default
    c.timeout = false
    c.timeout.should.eq false # false would disable default
  end

  would 'work for inheritance' do
    stub_request(:get, url).to_return(:body => '123')
    Class.new(simple).new.get(url).should.eq '123'
  end

  would 'not deadlock when exception was raised in the callback' do
    client = Class.new(simple).new
    stub_request(:get, url).to_return(:body => 'nnf')

    (-1..1).each do |size|
      mock(any_instance_of(RestBuilder::Promise)).warn(is_a(String)) do |msg|
        msg.should.include?('nnf')
      end
      client.class.pool_size = size
      client.get(url) do |body|
        raise body
      end
      client.class.shutdown
    end
  end

  would 'be able to access caller outside the callback' do
    flag = false
    client = simple.new
    stub_request(:get, url).to_return(:body => 'nnf')
    client.get(url) do
      current_file = /^#{__FILE__}/
                     caller.grep(current_file).should.empty?
      RestBuilder::Promise.backtrace.grep(current_file).should.not.empty?
      client.get(url) do
        RestBuilder::Promise.backtrace.last.should.not =~ /promise\.rb:\d+:in/
        flag = true
      end
    end
    client.wait
    flag.should.eq true # to make sure the inner most block did run
  end

  would 'call error_callback' do
    error = nil
    error_callback = lambda{ |e| error = e }
    should.raise(SystemCallError) do
      simple.new(:error_callback => error_callback).
        get('http://localhost:1').tap{}
    end
    error.should.kind_of?(SystemCallError)
  end

  would 'give RESPONSE_BODY' do
    stub_request(:get, url).to_return(:body => 'OK')
    simple.new.get(url).should.eq 'OK'
  end

  would 'give RESPONSE_HEADERS' do
    stub_request(:head, url).to_return(:headers => {'A' => 'B'})
    simple.new.head(url).should.eq 'A' => 'B'
  end

  would 'give RESPONSE_HEADERS' do
    stub_request(:get, url).to_return(:status => 199)
    simple.new.get(url, {},
      RestBuilder::RESPONSE_KEY => RestBuilder::RESPONSE_STATUS).should.eq 199
  end

  would 'give RESPONSE_SOCKET' do
    stub_request(:get, url).to_return(:body => 'OK')
    simple.new.get(url, {}, RestBuilder::HIJACK => true).read.should.eq 'OK'
  end

  would 'give REQUEST_URI' do
    stub_request(:get, "#{url}?a=b").to_return(:body => 'OK')
    simple.new.get(url, {:a => 'b'},
      RestBuilder::RESPONSE_KEY => RestBuilder::REQUEST_URI).
      should.eq "#{url}?a=b"
    simple.wait
  end

  would 'give unspecified payload like a hash' do
    client = RestBuilder::Builder.client{ run RestBuilder::Identity }.new
    payload = client.get(url, {},
      RestBuilder::RESPONSE_KEY => RestBuilder::REQUEST_PAYLOAD)

    payload.should.kind_of?(Hash)
    payload.should.kind_of?(RestBuilder::Payload::Unspecified)
  end
end
