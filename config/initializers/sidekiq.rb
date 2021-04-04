Sidekiq.configure_server do |config|
  config.redis = { url: "redis://#{REDIS_HOST}:#{REDIS_PORT}/#{REDIS_DB}" }
end
