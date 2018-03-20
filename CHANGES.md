# CHANGES

## rest-builder 1.0.0 -- 2018-03-20

### Potential breaking changes:

* Introduce `RestBuilder::Payload::Unspecified`, which would be used as the
  default payload. It's a class extended from `Hash`, which is only used to
  served the purpose of being unspecified. The rationale behind introducing
  this is keeping backward compatibility, while making it easier to tell
  if payload is specified or not. Before having this, we don't know if the
  payload is just empty, or not specified, causing the deleting method
  always attach an empty hash payload, introduced in 0.9.2. Not any more.
* `RestBuilder::Dry` would now make sure there are:

    * RESPONSE_STATUS
    * RESPONSE_HEADERS
    * RESPONSE_BODY

### New feature:

* Introduce `RestBuilder::Identity` as the previous `RestBuilder::Dry`.

## rest-builder 0.9.2 -- 2017-08-05

* Attach payload for DELETE request as well. See:
  [A payload within a DELETE request is ignored resulting "Invalid request data" from web services](https://github.com/godfat/rest-core/issues/25)

## rest-builder 0.9.1 -- 2016-03-04

* `Promise.set_backtrace` for errors from `event_source`.

## rest-builder 0.9.0 -- 2016-01-31

* Birthday!
