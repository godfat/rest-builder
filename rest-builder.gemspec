# -*- encoding: utf-8 -*-
# stub: rest-builder 1.0.0 ruby lib

Gem::Specification.new do |s|
  s.name = "rest-builder".freeze
  s.version = "1.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Lin Jen-Shin (godfat)".freeze]
  s.date = "2022-12-31"
  s.description = "Modular Ruby clients interface for REST APIs.\n\nBuild your own API clients for less dependencies, less codes, less memory,\nless conflicts, and run faster. Checkout [rest-core][] for pre-built\nmiddleware and [rest-more][] for pre-built clients.\n\n[rest-core]: https://github.com/godfat/rest-core\n[rest-more]: https://github.com/godfat/rest-more".freeze
  s.email = ["godfat (XD) godfat.org".freeze]
  s.files = [
  ".gitignore".freeze,
  ".gitlab-ci.yml".freeze,
  ".gitmodules".freeze,
  "CHANGES.md".freeze,
  "Gemfile".freeze,
  "README.md".freeze,
  "Rakefile".freeze,
  "lib/rest-builder.rb".freeze,
  "lib/rest-builder/builder.rb".freeze,
  "lib/rest-builder/client.rb".freeze,
  "lib/rest-builder/engine.rb".freeze,
  "lib/rest-builder/engine/dry.rb".freeze,
  "lib/rest-builder/engine/http-client.rb".freeze,
  "lib/rest-builder/engine/identity.rb".freeze,
  "lib/rest-builder/error.rb".freeze,
  "lib/rest-builder/event_source.rb".freeze,
  "lib/rest-builder/middleware.rb".freeze,
  "lib/rest-builder/payload.rb".freeze,
  "lib/rest-builder/promise.rb".freeze,
  "lib/rest-builder/test.rb".freeze,
  "lib/rest-builder/version.rb".freeze,
  "rest-builder.gemspec".freeze,
  "task/README.md".freeze,
  "task/gemgem.rb".freeze,
  "test/engine/test_dry.rb".freeze,
  "test/engine/test_identity.rb".freeze,
  "test/test_builder.rb".freeze,
  "test/test_client.rb".freeze,
  "test/test_event_source.rb".freeze,
  "test/test_future.rb".freeze,
  "test/test_httpclient.rb".freeze,
  "test/test_middleware.rb".freeze,
  "test/test_payload.rb".freeze]
  s.homepage = "https://github.com/godfat/rest-builder".freeze
  s.licenses = ["Apache-2.0".freeze]
  s.rubygems_version = "3.4.1".freeze
  s.summary = "Modular Ruby clients interface for REST APIs.".freeze
  s.test_files = [
  "test/engine/test_dry.rb".freeze,
  "test/engine/test_identity.rb".freeze,
  "test/test_builder.rb".freeze,
  "test/test_client.rb".freeze,
  "test/test_event_source.rb".freeze,
  "test/test_future.rb".freeze,
  "test/test_httpclient.rb".freeze,
  "test/test_middleware.rb".freeze,
  "test/test_payload.rb".freeze]

  s.specification_version = 4

  s.add_runtime_dependency(%q<promise_pool>.freeze, [">= 0"])
  s.add_runtime_dependency(%q<httpclient>.freeze, [">= 0"])
  s.add_runtime_dependency(%q<mime-types>.freeze, [">= 0"])
end
