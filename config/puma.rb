max_threads_count = ENV.fetch("RAILS_MAX_THREADS", 5)
min_threads_count = ENV.fetch("RAILS_MIN_THREADS", max_threads_count)
threads min_threads_count, max_threads_count

if ENV["PUMA_BIND"]
  bind ENV.fetch("PUMA_BIND")
else
  port ENV.fetch("PORT", 3000)
end
environment ENV.fetch("RAILS_ENV", "development")
pidfile ENV.fetch("PIDFILE", "tmp/pids/server.pid")

workers ENV.fetch("WEB_CONCURRENCY", 2) if ENV.fetch("RAILS_ENV", "development") == "production"
preload_app!
plugin :tmp_restart
