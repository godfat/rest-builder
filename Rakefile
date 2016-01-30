
begin
  require "#{dir = File.dirname(__FILE__)}/task/gemgem"
rescue LoadError
  sh 'git submodule update --init --recursive'
  exec Gem.ruby, '-S', $PROGRAM_NAME, *ARGV
end

$LOAD_PATH.unshift(File.expand_path("#{dir}/promise_pool/lib"))

Gemgem.init(dir) do |s|
  require 'rest-builder/version'
  s.name    = 'rest-builder'
  s.version = RestBuilder::VERSION
  %w[promise_pool httpclient mime-types].each do |g|
    s.add_runtime_dependency(g)
  end

  # exclude promise_pool
  s.files.reject!{ |f| f.start_with?('promise_pool/') }
end
