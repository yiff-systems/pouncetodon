# Be sure to restart your server when you modify this file.

# Configure sensitive parameters which will be filtered from the log file.
Rails.application.config.filter_parameters += [:password, :private_key, :public_key, :otp_attempt]

Sentry.init do |config|
  # they removed the filters :( https://github.com/getsentry/sentry-ruby/issues/1140
  config.before_send = lambda do |event, _hint|
    # note: if you have config.async configured, the event here will be a Hash instead of an Event object
    request_data = event.request.data
    mask = "[super_secret]".freeze

    Rails.application.config.filter_parameters.each do |filter_parameter|
      if sensitive_data = request_data[filter_parameter]
        request_data[filter_parameter] = mask
      end
    end

    event.request.data = request_data
    event
  end
end
