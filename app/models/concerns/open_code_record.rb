module OpenCodeRecord
  extend ActiveSupport::Concern

  private

  def parsed_json(value, fallback: {})
    parsed = JSON.parse(value.to_s)
    return parsed if fallback.nil?

    parsed.is_a?(fallback.class) ? parsed : fallback
  rescue JSON::ParserError, TypeError
    fallback
  end

  def epoch_time(value)
    return if value.blank?

    timestamp = value.to_i
    timestamp = Rational(timestamp, 1000) if timestamp > 99_999_999_999
    Time.zone.at(timestamp)
  end
end
