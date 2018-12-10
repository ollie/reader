require 'bundler/setup'
require_relative 'config/settings'

task :settings do
  Bundler.require(:default, Settings.environment)
  Settings.database
end

task environment: :settings do
  Settings.setup_i18n
  Settings.load_files('lib/**')
  Settings.load_files('models')
end

Dir['tasks/**/*.rake'].each { |task| import task }
