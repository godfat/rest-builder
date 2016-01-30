# -*- encoding: utf-8 -*-
# stub: rest-builder 0.9.0 ruby lib

Gem::Specification.new do |s|
  s.name = "rest-builder"
  s.version = "0.9.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Lin Jen-Shin (godfat)"]
  s.date = "2016-01-31"
  s.description = "Modular Ruby clients interface for REST APIs.\n\nBuild your own API clients for less dependencies, less codes, less memory,\nless conflicts, and run faster. Checkout [rest-core][] for pre-built\nmiddleware and [rest-more][] for pre-built clients.\n\n[rest-core]: https://github.com/godfat/rest-core\n[rest-more]: https://github.com/godfat/rest-more"
  s.email = ["godfat (XD) godfat.org"]
  s.files = [
  ".gitignore",
  ".gitmodules",
  ".travis.yml",
  "CHANGES.md",
  "Gemfile",
  "README.md",
  "Rakefile",
  "lib/rest-builder.rb",
  "lib/rest-builder/builder.rb",
  "lib/rest-builder/client.rb",
  "lib/rest-builder/engine.rb",
  "lib/rest-builder/engine/dry.rb",
  "lib/rest-builder/engine/http-client.rb",
  "lib/rest-builder/error.rb",
  "lib/rest-builder/event_source.rb",
  "lib/rest-builder/middleware.rb",
  "lib/rest-builder/payload.rb",
  "lib/rest-builder/promise.rb",
  "lib/rest-builder/test.rb",
  "lib/rest-builder/version.rb",
  "rest-builder.gemspec",
  "task/README.md",
  "task/gemgem.rb",
  "test/test_builder.rb",
  "test/test_client.rb",
  "test/test_event_source.rb",
  "test/test_future.rb",
  "test/test_httpclient.rb",
  "test/test_payload.rb"]
  s.homepage = "https://github.com/godfat/rest-builder"
  s.licenses = ["Apache License 2.0"]
  s.rubygems_version = "2.5.1"
  s.summary = "Modular Ruby clients interface for REST APIs."
  s.test_files = [
  "test/test_builder.rb",
  "test/test_client.rb",
  "test/test_event_source.rb",
  "test/test_future.rb",
  "test/test_httpclient.rb",
  "test/test_payload.rb"]

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<promise_pool>, [">= 0"])
      s.add_runtime_dependency(%q<httpclient>, [">= 0"])
      s.add_runtime_dependency(%q<mime-types>, [">= 0"])
    else
      s.add_dependency(%q<promise_pool>, [">= 0"])
      s.add_dependency(%q<httpclient>, [">= 0"])
      s.add_dependency(%q<mime-types>, [">= 0"])
    end
  else
    s.add_dependency(%q<promise_pool>, [">= 0"])
    s.add_dependency(%q<httpclient>, [">= 0"])
    s.add_dependency(%q<mime-types>, [">= 0"])
  end
end
