class Service::UpdateChannel
  class Error < StandardError; end

  REQUEST_OPTS = {
    followlocation: true,
    maxredirs:      3,
    timeout:        5,
    connecttimeout: 10,
    headers: {
      'User-Agent' => 'RSS Reader - https://github.com/ollie/reader',
      'Accept'     => 'application/rss+xml'
    }
  }.freeze

  attr_accessor :channel

  def self.perform(channel)
    new(channel).perform
  end

  def initialize(channel)
    self.channel = channel
  end

  def perform
    channel.update(status: nil)
    response = prepare_request.run
    feed     = parse_feed(response)

    feed.items.each do |item|
      add_item(item)
    end
  rescue Error => e
    channel.update(status: e.message)
    raise
  end

  private

  def prepare_request
    request = Typhoeus::Request.new(channel.feed_link, REQUEST_OPTS)
    install_error_hooks(request)
    request
  end

  def install_error_hooks(request)
    request.on_complete do |response|
      raise Error, I18n.t('request_timed_out') if response.timed_out?
      raise Error, I18n.t('request_failed', message: response.return_message) if response.code.zero?
      raise Error, I18n.t('request_failed', message: response.code) unless response.success?
    end
  end

  def parse_feed(response)
    Yarss.new(response.body)
  rescue Yarss::Error => e
    raise Error, I18n.t('not_a_rss_feed', message: e.message[0, 200])
  end

  def add_item(item)
    item = Item.new(
      channel_id:  channel.id,
      title:       item.title,
      link:        item.link,
      description: item.content,
      author:      item.author,
      guid:        item.id,
      pub_date:    item.updated_at
    )
    item.validate
    return if item.errors.on([:channel_id, :guid])
    item.save
  rescue Sequel::UniqueConstraintViolation
    nil # That's ok.
  end
end
