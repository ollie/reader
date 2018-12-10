desc 'Run console'
task console: :environment do
  require 'pry'
  Pry.start
end

desc 'Run console'
task c: :console
