
require 'rest-builder/middleware'

module RestBuilder
  class Dry
    include Middleware
    def call env
      yield(env)
    end
  end
end
