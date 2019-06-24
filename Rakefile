require 'bundler/setup'
require_relative 'config/settings'

task :settings do
  Bundler.require(:default, Settings.environment)
  Settings.database
end

task environment: :settings do
  Settings.setup_i18n
  Settings.autoloader
end

Dir['tasks/**/*.rake'].each { |task| import task }
