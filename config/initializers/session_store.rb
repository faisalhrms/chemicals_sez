Rails.application.config.session_store :cookie_store,
  key: "_sapphire_sez_portal_session",
  secure: Rails.env.production? && ENV.fetch("FORCE_SSL", "true") == "true",
  httponly: true,
  same_site: :lax
