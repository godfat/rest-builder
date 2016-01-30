
source 'https://rubygems.org/'

gemspec

gem 'rake'
gem 'pork'
gem 'muack'
gem 'webmock'

gem 'simplecov', :require => false if ENV['COV']
gem 'coveralls', :require => false if ENV['CI']

platforms :rbx do
  gem 'rubysl-weakref'    # used in rest-core
  gem 'rubysl-socket'     # used in test
  gem 'rubysl-singleton'  # used in rake
  gem 'rubysl-rexml'      # used in crack used in webmock
  gem 'rubysl-bigdecimal' # used in crack used in webmock
end

platforms :jruby do
  gem 'jruby-openssl'
end
