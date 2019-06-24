class Service::UpdateChannels
  attr_accessor :channels

  def self.perform(channels)
    new(channels).perform
  end

  def initialize(channels)
    self.channels = channels
  end

  def perform
    pool = Concurrent::ThreadPoolExecutor.new(
      min_threads: 2,
      max_threads: 5
    )

    channels.each do |channel|
      pool.post { update_channel(channel) }
    end

    pool.shutdown
    pool.wait_for_termination
  end

  private

  def update_channel(channel)
    UpdateChannel.perform(channel)
  rescue UpdateChannel::Error
    nil # That's ok.
  end
end
