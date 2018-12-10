namespace :db do
  desc 'Run database migrations'
  task :migrate, [:version] => :settings do |_t, args|
    Sequel.extension(:migration)

    opts = {}

    if args[:version]
      puts "Migrating to version #{args[:version]}"
      opts[:target] = args[:version].to_i
    else
      puts 'Migrating to latest'
    end

    Sequel::Migrator.run(Settings.database, 'db/migrations', opts)
    Rake::Task['db:schema_dump'].invoke if
      Settings.development? && ENV['DUMP'] != '0'
  end

  # TODO: How to dump functions?
  desc 'Dump database schema'
  task schema_dump: :settings do
    db_url      = Settings.database_url
    schema_path = 'db/schema.rb'

    sh "sequel -D #{db_url} > #{schema_path}"
    sh "rubocop -a #{schema_path}"
  end
end
