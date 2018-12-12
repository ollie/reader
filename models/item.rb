class Item < Sequel::Model
  #########
  # Plugins
  #########

  plugin :validation_helpers
  plugin :translated_validation_messages
  plugin :defaults_setter
  plugin :dirty
  plugin :timestamps, update_on_create: true

  ##############
  # Associations
  ##############

  many_to_one :channel

  #################
  # Dataset methods
  #################

  dataset_module do
    def mark_as_read
      update(read: true)
    end
  end

  #############
  # Validations
  #############

  def validate
    super

    validates_presence [
      :title,
      :channel_id,
      :link,
      :guid
    ]

    validates_max_length 255, :title
    validates_max_length 255, :author, allow_nil: true
    validates_max_length 255, :guid

    validates_unique [:channel_id, :guid]
  end

  #########################
  # Public instance methods
  #########################

  def sanitized_description
    description
      .gsub(/onmouse[^=]*="[^"]*"\s*/i, '')
      .gsub(/onclick[^=]*="[^"]*"\s*/i, '')
      .gsub(/<font.*?>/i, '')
      .gsub(%r{</font>}i, '')
  end

  def info
    s = ''

    if pub_date
      s << I18n.l(pub_date)
      s << ', ' if author.present?
    end

    s << author if author.present?

    s unless s.empty?
  end

  def mark_as_read
    update(read: true)
  end

  def mark_as_unread
    update(read: false)
  end
end
