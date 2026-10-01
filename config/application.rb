require_relative "boot"

require "rails/all"

Bundler.require(*Rails.groups)

module SapphireSezPortal
  class Application < Rails::Application
    config.load_defaults 8.1

    config.time_zone = "Asia/Karachi"
    config.active_record.default_timezone = :utc
    config.assets.integrity_hash_algorithm = "sha256"

    # Uploaded project documents must only be served through authorized controllers.
    config.active_storage.draw_routes = false

    # Keep headers explicit and conservative.
    config.action_dispatch.default_headers.merge!({
      "X-Content-Type-Options" => "nosniff",
      "X-Frame-Options" => "SAMEORIGIN",
      "Referrer-Policy" => "strict-origin-when-cross-origin",
      "Cross-Origin-Opener-Policy" => "same-origin",
      "Cross-Origin-Resource-Policy" => "same-origin"
    })
  end
end
