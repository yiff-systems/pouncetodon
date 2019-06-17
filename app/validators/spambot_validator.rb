class SpambotValidator < ActiveModel::Validator
  def validate(status)
    # allow local spammers and potential reblogs
    return if status.local? || status.reblog?

    @status = status

    status.errors.add(:text, "Oopsie woopsie uwu") if should_filter?
  end

  private

  def should_filter?
    return true if @status.text =~ /Things I hate: feminism, gays, blacks/

    false
  end
end
