path = Rails.root.join("config/sentry_dsn")
return unless File.exists?(path)

Raven.configure do |config|
  config.dsn = File.read(path).strip
end
