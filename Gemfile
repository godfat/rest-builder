
source 'https://rubygems.org/'

gemspec

gem 'promise_pool', :path => 'promise_pool'

gem 'rake'
gem 'pork'
gem 'muack'
gem 'webmock'

gem 'simplecov', :require => false if ENV['COV']
gem 'coveralls', :require => false if ENV['CI']

platforms :jruby do
  gem 'jruby-openssl'
end
