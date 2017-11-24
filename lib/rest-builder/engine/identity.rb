
require 'rest-builder/middleware'

module RestBuilder
  class Identity
    include Middleware
    def call env
      yield(env)
    end
  end
end
