# Be sure to restart your server when you modify this file.

Rails.application.config.action_dispatch.rack_cache = {
  metastore: "redis://#{REDIS_HOST}:#{REDIS_PORT}/#{REDIS_DB}/metastore",
  entitystore: "redis://#{REDIS_HOST}:#{REDIS_PORT}/#{REDIS_DB}/entitystore"
}
