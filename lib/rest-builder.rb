
require 'rest-builder/builder'
require 'rest-builder/engine/identity'

module RestBuilder
  REQUEST_METHOD   = 'REQUEST_METHOD'
  REQUEST_PATH     = 'REQUEST_PATH'
  REQUEST_QUERY    = 'REQUEST_QUERY'
  REQUEST_PAYLOAD  = 'REQUEST_PAYLOAD'
  REQUEST_HEADERS  = 'REQUEST_HEADERS'
  REQUEST_URI      = 'REQUEST_URI'

  RESPONSE_BODY    = 'RESPONSE_BODY'
  RESPONSE_STATUS  = 'RESPONSE_STATUS'
  RESPONSE_HEADERS = 'RESPONSE_HEADERS'
  RESPONSE_SOCKET  = 'RESPONSE_SOCKET'
  RESPONSE_KEY     = 'RESPONSE_KEY'

  DRY              = 'core.dry'
  FAIL             = 'core.fail'
  LOG              = 'core.log'
  CLIENT           = 'core.client'

  ASYNC            = 'async.callback'
  TIMER            = 'async.timer'
  PROMISE          = 'async.promise'
  HIJACK           = 'async.hijack'
end
