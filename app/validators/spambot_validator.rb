class SpambotValidator < ActiveModel::Validator
  def validate(status)
    # allow local spammers and potential reblogs
    return if status.local? || status.reblog?

    @status = status

    if should_filter?
      Rails.logger.warn("filtering status from account_id #{status.account_id}")
      status.errors.add(:text, "Oopsie woopsie uwu")
    end
  end

  private

  def should_filter?
    return true if @status.text =~ /Things I hate: feminism, gays, blacks/

    false
  end
end
