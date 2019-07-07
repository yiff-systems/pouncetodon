# frozen_string_literal: true

class SpambotValidator < ActiveModel::Validator
  FILTER_MATCHERS = {
    things_i_hate: /Things I hate: feminism, gays, blacks/.freeze,
    was_blog_link: %r{(?:<a href=")?https?://womenare(?:stupid|dumb).site/blog/}.freeze,
  }.freeze

  REDIS_LOG_KEY = "nilsding:spambotvalidator:log"

  def validate(status)
    # allow local spammers and potential reblogs
    return if (status.local? && !Rails.env.development?) || status.reblog?

    @status = status

    unless filter_reasons.empty?
      Rails.logger.error("filtering status from account_id #{status.account_id} -- reason: #{filter_reasons.join(', ')}")
      status.errors.add(:text, "Oopsie woopsie uwu")
    end
  end

  private

  def filter_reasons
    @filter_reasons ||= [].tap do |reasons|
      FILTER_MATCHERS.each do |reason, regexp|
        reasons << reason if @status.text =~ regexp
      end

      next if reasons.empty?

      Redis.current.lpush(REDIS_LOG_KEY, "#{Time.now.utc.to_f}$$#{reasons.join(',')}$$#{@status.account_id}")
    end
  end
end
