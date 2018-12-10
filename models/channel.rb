class Channel < Sequel::Model
  #########
  # Plugins
  #########

  plugin :validation_helpers
  plugin :translated_validation_messages
  plugin :defaults_setter
  plugin :eager_each
  plugin :timestamps, update_on_create: true

  ##############
  # Associations
  ##############

  one_to_many :items, order: Sequel.desc(:pub_date)
  # one_to_many :unread_items, class: :Item do |ds|
  #   ds.where(read: false)
  # end

  #############
  # Validations
  #############

  def validate
    super

    validates_presence [
      :title,
      :feed_link,
      :html_link
    ]

    validates_max_length 255, :title
    validates_max_length 255, :feed_link
    validates_max_length 255, :html_link
    validates_max_length 255, :status, allow_nil: true

    validates_unique :feed_link
    validates_format %r{\Ahttps?://}, :feed_link, message: I18n.t('sequel.errors.invalid_url')
    validates_format %r{\Ahttps?://}, :html_link, message: I18n.t('sequel.errors.invalid_url')
  end

  #################
  # Dataset methods
  #################

  dataset_module do
    # Collections

    def enabled
      where(enabled: true)
    end

    def ordered_for_reader
      order(Sequel.desc(:unread_items_count), :title)
    end

    def ordered_for_channels_list
      order(Sequel.desc(:enabled), Sequel.desc(:unread_items_count), :title)
    end
  end

  def mark_as_read
    items_dataset.mark_as_read
  end
end
