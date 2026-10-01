require "active_support/core_ext/integer/time"

Rails.application.configure do
  config.enable_reloading = false
  config.eager_load = true
  config.consider_all_requests_local = false
  config.server_timing = false

  config.public_file_server.headers = { "cache-control" => "public, max-age=#{1.year.to_i}" }
  config.active_storage.service = ENV.fetch("ACTIVE_STORAGE_SERVICE", "local").to_sym

  config.force_ssl = ENV.fetch("FORCE_SSL", "true") == "true"
  config.assume_ssl = config.force_ssl

  # HostAuthorization protects against Host header / DNS rebinding attacks.
  if ENV["APP_HOST"].present?
    config.hosts << ENV.fetch("APP_HOST")
  end

  config.log_tags = [ :request_id ]
  config.logger = ActiveSupport::TaggedLogging.logger(STDOUT)
  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")

  config.active_support.report_deprecations = false
  config.active_record.dump_schema_after_migration = false
  config.active_record.attributes_for_inspect = [ :id ]

  config.action_mailer.default_url_options = {
    host: ENV.fetch("APP_HOST"),
    port: ENV["APP_PORT"],
    protocol: config.force_ssl ? "https" : "http"
  }
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    address: ENV.fetch("SMTP_ADDRESS", "localhost"),
    port: ENV.fetch("SMTP_PORT", 587),
    user_name: ENV["SMTP_USERNAME"],
    password: ENV["SMTP_PASSWORD"],
    domain: ENV.fetch("SMTP_DOMAIN", ENV.fetch("APP_HOST")),
    authentication: :plain,
    enable_starttls_auto: true
  }
end
