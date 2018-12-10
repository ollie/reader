class App < Sinatra::Base
  set :slim, layout: :'layouts/application',
             pretty: true
  enable :sessions
  register Sinatra::Flash

  configure do
    config = YAML.safe_load(File.read("#{settings.root}/config/secrets.yml"))
    config = config.fetch(Settings.environment)

    set :login_encrypted_username, config.fetch('login_encrypted_username')
    set :login_encrypted_password, config.fetch('login_encrypted_password')

    Settings.database
    Settings.setup_i18n
    Settings.load_files('lib/**')
    Settings.load_files('models/**')
  end

  use Rack::Auth::Basic, 'Whee' do |username, password|
    encrypted_username = Digest::SHA256.hexdigest(username)
    encrypted_password = Digest::SHA256.hexdigest(password)

    encrypted_username == settings.login_encrypted_username &&
      encrypted_password == settings.login_encrypted_password
  end if Settings.production?

  def self.Route(hash)
    route_name = hash.keys.first
    route_path = hash[route_name]

    helpers do
      define_method("#{route_name}_path") do |id = nil|
        if route_path =~ /:id/
          raise ArgumentError, "Missing :id parameter for route #{route_path}" unless id
          route_path.gsub(':id', id.to_s)
        else
          route_path
        end
      end
    end

    route_path
  end

  helpers do
    def partial_slim(template, locals = {})
      slim(template.to_sym, layout: false, locals: locals)
    end

    def title(text = nil, head: false)
      return @title = text if text
      return [@title, t('title')].compact.join(' – ') if head

      @title
    end

    def icon(filename)
      @@icon_cache ||= {}
      @@icon_cache[filename] ||= begin
        svg = Settings.root.join('public/svg/octicons', "#{filename}.svg").read
        %(<span class="octicon">#{svg}</span>)
      end
    end

    def t(key, options = nil)
      I18n.t(key, options)
    end

    def l(key, options = nil)
      I18n.l(key, options)
    end

    def json(data)
      MultiJson.dump(data, pretty: !Settings.production?)
    end

    def mustache(view_path, locals = {})
      template = read_mustache_template(view_path)
      Mustache.render(template, locals)
    end

    def read_mustache_template(view_path)
      @mustache_cache ||= {}
      @mustache_cache[view_path] ||= File.read("#{settings.views}/#{view_path}.mustache")
    end

    def item_data_for_mustache(item, index)
      {
        active:   index.zero?,
        item_url: api_item_path(item.id),
        title:    item.title,
        read:     item.read
      }
    end
  end

  #######
  # Items
  #######

  get Route(items: '/') do
    if Channel.count.zero?
      redirect new_channel_path
    else
      channels = Channel.enabled.ordered_for_reader
      items    = channels.first.items_dataset.limit(30)
      item     = items.first

      slim :'items/index', layout: :'layouts/items', locals: {
        channels: channels,
        items:    items,
        item:     item
      }
    end
  end

  #####
  # API
  #####

  get Route(api_mark_channels_as_read: '/api/channels/mark-as-read') do
    Item.mark_as_read
    redirect items_path
  end

  get Route(api_sync_channels: '/api/channels/sync') do
    UpdateChannels.perform(Channel.all)
    redirect items_path
  end

  get Route(api_channel: '/api/channels/:id.json') do
    channel = Channel.with_pk!(params[:id])
    items   = channel.items_dataset.limit(30)

    items_data = items.map do |item|
      {
        item_url: api_item_path(item.id),
        title:    item.title,
        read:     item.read
      }
    end

    item = items.first

    item_data = {
      title: item.title,
      link: item.link,
      info: item.info,
      read: item.read,
      mark_as_read_url: api_mark_item_as_read_path(item.id),
      mark_as_unread_url: api_mark_item_as_unread_path(item.id),
      description: item.description
    }

    data = {
      sync_channel_url: api_sync_channel_path(channel.id),
      mark_channel_as_read_url: api_mark_channel_as_read_path(channel.id),
      items: items_data,
      item: item_data
    }

    json data
  end

  get Route(api_mark_channel_as_read: '/api/channels/:id/mark-as-read') do
    channel = Channel.with_pk!(params[:id])
    channel.mark_as_read
    redirect items_path
  end

  get Route(api_sync_channel: '/api/channels/:id/sync') do
    channel = Channel.with_pk!(params[:id])

    begin
      UpdateChannel.perform(channel)
    rescue UpdateChannel::Error
      nil
    end

    redirect items_path
  end

  get Route(api_item: '/api/items/:id.json') do
    item = Item.with_pk!(params[:id])
    data = {
      title: item.title,
      link: item.link,
      info: item.info,
      read: item.read,
      mark_as_read_url: api_mark_item_as_read_path(item.id),
      mark_as_unread_url: api_mark_item_as_unread_path(item.id),
      description: item.description
    }

    json data
  end

  patch Route(api_mark_item_as_read: '/api/items/:id/mark-as-read') do
    item = Item.with_pk!(params[:id])
    item.mark_as_read
    halt 204
  end

  patch Route(api_mark_item_as_unread: '/api/items/:id/mark-as-unread') do
    item = Item.with_pk!(params[:id])
    item.mark_as_unread
    halt 204
  end

  ##########
  # Channels
  ##########

  get Route(channels: '/channels') do
    channels = Channel.ordered_for_channels_list

    if channels.empty?
      redirect new_channel_path
    else
      slim :'channels/index', locals: {
        channels: channels
      }
    end
  end

  post Route(sync_channels: '/channels/sync') do
    UpdateChannels.perform(Channel.all)
    flash[:success] = t('channels_synced')
    redirect channels_path
  end

  get Route(new_channel: '/channels/new') do
    channel = Channel.new

    slim :'channels/new', locals: {
      channel: channel
    }
  end

  post Route(confirm_channel: '/channels/confirm') do
    channel = Channel.new
    channel.set_fields(params[:channel], [:enabled, :feed_link])
    channel.validate

    if channel.errors.on(:feed_link)
      slim :'channels/new', locals: {
        channel: channel
      }
    else
      channel.errors.clear

      begin
        ReadChannelInfo.perform(channel)
        slim :'channels/confirm', locals: {
          channel: channel
        }
      rescue ReadChannelInfo::Error => e
        flash.now[:error] = e.message
        slim :'channels/new', locals: {
          channel: channel
        }
      end
    end
  end

  post '/channels/new' do
    channel = Channel.new
    channel.set_fields(params[:channel], [:enabled, :title, :feed_link, :html_link])

    if channel.valid?
      channel.save

      begin
        UpdateChannel.perform(channel)
      rescue UpdateChannel::Error => e
        flash[:error] = e.message
      end

      flash[:success] = t('channel_created')
      redirect channels_path
    else
      slim :'channels/confirm', locals: {
        channel: channel
      }
    end
  end

  get Route(edit_channel: '/channels/:id/edit') do
    slim :'channels/edit', locals: {
      channel: Channel.with_pk!(params[:id])
    }
  end

  post '/channels/:id/edit' do
    channel = Channel.with_pk!(params[:id])
    channel.set_fields(params[:channel], [:enabled, :title, :feed_link, :html_link])

    if channel.valid?
      channel.save
      flash[:success] = t('channel_updated')
      redirect channels_path
    else
      slim :'channels/edit', locals: {
        channel: channel
      }
    end
  end

  post Route(sync_channel: '/channels/:id/sync') do
    channel = Channel.with_pk!(params[:id])

    begin
      UpdateChannel.perform(channel)
      flash[:success] = t('channel_synced')
    rescue UpdateChannel::Error => e
      flash[:error] = e.message
    end

    redirect channels_path
  end

  post Route(delete_channel: '/channels/:id/delete') do
    channel = Channel.with_pk!(params[:id])
    channel.destroy
    flash[:success] = t('channel_deleted')
    redirect channels_path
  end
end
