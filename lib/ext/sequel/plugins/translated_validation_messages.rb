module Sequel::Plugins::TranslatedValidationMessages
  module InstanceMethods
    private

  # DEFAULT_OPTIONS = {
  #   exact_length: { message: ->(exact) { "is not #{exact} characters" } },
  #   format:       { message: ->(_with) { 'is invalid' } },
  #   includes:     { message: ->(set) { "is not in range or set: #{set.inspect}" } },
  #   integer:      { message: -> { 'is not a number' } },
  #   length_range: { message: ->(_range) { 'is too short or too long' } },
  #   max_length:   { message: ->(max) { "is longer than #{max} characters" }, nil_message: -> { 'is not present' } },
  #   min_length:   { message: ->(min) { "is shorter than #{min} characters" } },
  #   not_null:     { message: -> { 'is not presentx' } },
  #   numeric:      { message: -> { 'is not a number' } },
  #   operator:     { message: ->(operator, rhs) { "is not #{operator} #{rhs}" } },
  #   type:         { message: ->(klass) { klass.is_a?(Array) ? "is not a valid #{klass.join(' or ').downcase}" : "is not a valid #{klass.to_s.downcase}" } },
  #   presence:     { message: -> { 'is not presentx' } },
  #   unique:       { message: -> { 'is already taken' } }
  # }.freeze
  def default_validation_helpers_options(type)
    case type
    when :presence
      { message: -> { I18n.t('sequel.errors.presence') } }
    else
      super
    end
  end
  end
end
