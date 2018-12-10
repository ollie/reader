require 'logger'
require 'yaml'

module Settings
  extend self

  def root
    @root ||= Pathname.new(File.expand_path('..', __dir__))
  end

  def environment
    @environment ||= ENV['RACK_ENV'] || 'development'
  end

  def development?
    environment == 'development'
  end

  def production?
    environment == 'production'
  end

  def load_files(path)
    Dir[root.join(path, '*.rb')].each { |file| require file }
  end

  def database
    @database ||= begin
      # Convert all times to UTC while saving and loading.
      Sequel.default_timezone = :utc
      Sequel.connect(
        database_url,
        encoding:        'utf-8',
        logger:          (development? ? Logger.new($stdout) : nil),
        max_connections: pool_size
      ).tap do |database|
        database.extension(:connection_validator)
      end
    end
  end

  def database_url
    @database_url ||= begin
      config = YAML.load(root.join('config/database.yml').read).fetch(environment)
      "postgres://#{config['username']}:#{config['password']}@localhost/#{config['database']}"
    end
  end

  def setup_i18n
    I18n.load_path = Dir[root.join('config/locales/**/*.{rb,yml}')]
    I18n.available_locales = [:cs]
    I18n.default_locale = :cs
  end

  private

  def pool_size
    @pool_size ||= (ENV['POOL_SIZE'] || 5).to_i
  end
end
