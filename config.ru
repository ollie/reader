require 'bundler'
require_relative 'config/settings'
Bundler.require(:default, :web, Settings.environment)
Settings.autoloader

if defined?(PhusionPassenger)
  PhusionPassenger.on_event(:starting_worker_process) do |forked|
    Settings.database.disconnect if forked
  end
end

run App
