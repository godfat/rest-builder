
require 'thread'
require 'weakref'

require 'rest-builder/promise'
require 'rest-builder/middleware'
require 'rest-builder/engine/dry'

module RestBuilder
  module Client
    Unserializable = [Proc, Method, IO]

    def self.included mod
      # honor default attributes
      src = mod.members.map{ |name|
        <<-RUBY
          def #{name}
            if (r = super).nil?
              self.#{name} = default_#{name}
            else
              r
            end
          end

          def default_#{name} a=app
            if self.class.respond_to?("default_#{name}")
              self.class.default_#{name}      # old class default style
            elsif a.respond_to?(:#{name})
              a.#{name}({})                 # middleware instance value
            elsif a.respond_to?(:app)
              default_#{name}(a.app)        # walk into next app
            else
              nil
            end
          end
          private :default_#{name}
        RUBY
      }
      accessor = Module.new
      accessor.module_eval(src.join("\n"), __FILE__, __LINE__)
      mod.const_set('Accessor', accessor)
      mod.send(:include, accessor)
    end

    attr_reader :app, :dry, :promises
    attr_accessor :error_callback
    def initialize o={}
      @app ||= self.class.builder.to_app # lighten! would reinitialize anyway
      @dry ||= self.class.builder.to_app(Dry)
      @promises = []  # don't record any promises in lighten!
      @mutex    = nil # for locking promises, lazily initialized
                      # for serialization
      @error_callback = nil
      o.each{ |key, value| send("#{key}=", value) if respond_to?("#{key}=") }
    end

    def attributes
      Hash[each_pair.map{ |k, v| [k, send(k)] }]
    end

    def inspect
      fields = if size > 0
                 attributes.map{ |k, v|
                   "#{k}=#{v.inspect.sub(/(?<=.{12}).{4,}/, '...')}"
                 }.join(', ')
               else
                 ''
               end
      "#<struct #{self.class.name}#{fields}>"
    end

    def lighten! o={}
      attributes.each{ |k, v| vv = case v;
                                     when  Hash; lighten_hash(v)
                                     when Array; lighten_array(v)
                                     when *Unserializable; nil
                                     else v
                                   end
                              send("#{k}=", vv)}
      initialize(o)
      @app, @dry = lighten_app(app), lighten_app(dry)
      self
    end

    def lighten o={}
      dup.lighten!(o)
    end

    def wait
      self.class.wait(promises, mutex)
      self
    end

    def url path, query={}, opts={}
      dry.call(build_env({
        REQUEST_PATH  => path,
        REQUEST_QUERY => query,
        DRY           => true}.merge(opts)), &Middleware.method(:request_uri))
    end

    def get    path, query={}, opts={}, &cb
      request(
        {REQUEST_METHOD  => :get   ,
         REQUEST_PATH    => path   ,
         REQUEST_QUERY   => query  }.merge(opts), &cb)
    end

    def delete path, query={}, opts={}, &cb
      request(
        {REQUEST_METHOD  => :delete,
         REQUEST_PATH    => path   ,
         REQUEST_QUERY   => query  }.merge(opts), &cb)
    end

    def head path, query={}, opts={}, &cb
      request(
        {REQUEST_METHOD  => :head  ,
         REQUEST_PATH    => path   ,
         REQUEST_QUERY   => query  ,
         RESPONSE_KEY    => RESPONSE_HEADERS}.merge(opts), &cb)
    end

    def options path, query={}, opts={}, &cb
      request(
        {REQUEST_METHOD  => :options,
         REQUEST_PATH    => path   ,
         REQUEST_QUERY   => query  ,
         RESPONSE_KEY    => RESPONSE_HEADERS}.merge(opts), &cb)
    end

    def post   path, payload={}, query={}, opts={}, &cb
      request(
        {REQUEST_METHOD  => :post  ,
         REQUEST_PATH    => path   ,
         REQUEST_QUERY   => query  ,
         REQUEST_PAYLOAD => payload}.merge(opts), &cb)
    end

    def put    path, payload={}, query={}, opts={}, &cb
      request(
        {REQUEST_METHOD  => :put   ,
         REQUEST_PATH    => path   ,
         REQUEST_QUERY   => query  ,
         REQUEST_PAYLOAD => payload}.merge(opts), &cb)
    end

    def patch  path, payload={}, query={}, opts={}, &cb
      request(
        {REQUEST_METHOD  => :patch ,
         REQUEST_PATH    => path   ,
         REQUEST_QUERY   => query  ,
         REQUEST_PAYLOAD => payload}.merge(opts), &cb)
    end

    def event_source path, query={}, opts={}
      self.class.event_source_class.new(self, path, query, opts)
    end

    def request env, a=app
      if block_given?
        request_full(env, a){ |response| yield(response[response_key(env)]) }
      else
        request_full(env, a)[response_key(env)]
      end
    end

    def request_full env, a=app, &k
      response = a.call(build_env({ASYNC => !!k}.merge(env))) do |res|
        (k || :itself.to_proc).call(request_complete(res))
      end

      give_promise(response)

      if block_given?
        self
      else
        response
      end
    end

    def give_promise response
      # under ASYNC callback, response might not be a response hash
      # in that case (maybe in a user created engine), Client#wait
      # won't work because we have no way to track the promise.
      if response.kind_of?(Hash) && response[PROMISE]
        weak_promise = WeakRef.new(response[PROMISE])
        self.class.give_promise(weak_promise)
        self.class.give_promise(weak_promise, promises, mutex)
      end

      response
    end

    def build_env env={}
      default_env.merge(
        Middleware.string_keys(attributes).merge(Middleware.string_keys(env)))
    end

    def default_env
      {REQUEST_METHOD  => :get,
       REQUEST_PATH    => '/' ,
       REQUEST_QUERY   => {}  ,
       REQUEST_PAYLOAD => {}  ,
       REQUEST_HEADERS => {}  ,
       FAIL            => []  ,
       LOG             => []  ,
       CLIENT          => self}
    end
    # ------------------------ instance ---------------------



    private
    def request_complete res
      if err = res[FAIL].find{ |f| f.kind_of?(Exception) }
        Promise.set_backtrace(err) unless err.backtrace
        error_callback.call(err) if error_callback
        if res[ASYNC]
          res.merge(response_key(res) => err)
        elsif res[PROMISE] # promise would handle the exception for us
          err
        else
          raise err
        end
      else
        res
      end
    end

    def mutex
      @mutex ||= Mutex.new
    end

    def response_key opts
      opts[RESPONSE_KEY] ||
        if opts[HIJACK] then RESPONSE_SOCKET else RESPONSE_BODY end
    end

    def lighten_hash hash
      Hash[hash.map{ |(key, value)|
        case value
          when  Hash; lighten_hash(value)
          when Array; lighten_array(value)
          when *Unserializable; [key, nil]
          else [key, value]
        end
      }]
    end

    def lighten_array array
      array.map{ |value|
        case value
          when  Hash; lighten_hash(value)
          when Array; lighten_array(value)
          when *Unserializable; nil
          else value
        end
      }.compact
    end

    def lighten_app app
      members = if app.class.respond_to?(:members)
                  app.class.members.map{ |key|
                    case value = app.send(key, {})
                      when  Hash; lighten_hash(value)
                      when Array; lighten_array(value)
                      when *Unserializable; nil
                      else value
                    end
                  }
                else
                  []
                end

      if app.respond_to?(:app) && app.app
        app.class.new(lighten_app(app.app), *members)
      else
        app.class.new(*members)
      end
    end
  end
end
