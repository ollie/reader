source 'https://rubygems.org'

gem 'concurrent-ruby', require: 'concurrent'
gem 'concurrent-ruby-ext'
gem 'i18n'
gem 'logger'
gem 'multi_json'
gem 'multi_xml'
gem 'oj'
gem 'ox'
gem 'pg'
gem 'pry', require: false
gem 'rake', require: false
gem 'reline', require: false
gem 'sequel'
gem 'sequel_pg', require: 'sequel'
gem 'sequel_postgresql_triggers'
gem 'typhoeus'
gem 'yarss'
gem 'zeitwerk'

# Modes

group :web do
  gem 'mustache'
  gem 'sinatra', require: 'sinatra/base'
  gem 'sinatra-flash'
  gem 'slim'
end

# Environments

group :development do
  gem 'capistrano-bundler', require: false
  gem 'capistrano-passenger', require: false
  gem 'capistrano-rbenv', require: false
  gem 'ed25519', require: false      # Required for Capistrano to work with ed25519 key.
  gem 'bcrypt_pbkdf', require: false # Required for Capistrano to work with ed25519 key.
  gem 'listen', require: false # assets
  gem 'pry-byebug', require: false
  gem 'pry-doc', require: false
  gem 'puma', require: false
  gem 'rubocop', require: false
end
