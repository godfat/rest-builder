
require 'rest-builder/middleware'

module RestBuilder
  class Dry
    include Middleware
    def call env
      yield({RESPONSE_STATUS => 200,
             RESPONSE_HEADERS => {},
             RESPONSE_BODY => ''}.merge(env))
    end
  end
end
