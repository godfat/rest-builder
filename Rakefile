
begin
  require "#{__dir__}/task/gemgem"
rescue LoadError
  sh 'git submodule update --init --recursive'
  exec Gem.ruby, '-S', $PROGRAM_NAME, *ARGV
end

Gemgem.init(__dir__, :submodules => %w[promise_pool]) do |s|
  require 'rest-builder/version'
  s.name    = 'rest-builder'
  s.version = RestBuilder::VERSION

  %w[promise_pool httpclient mime-types].
    each(&s.method(:add_runtime_dependency))
end
