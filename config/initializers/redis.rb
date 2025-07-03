if Rails.env.production?
  $redis = Redis.new(url: ENV.fetch('REDIS_URL') { 'redis://localhost:6379/1' })
else
  # Для dev/test, если Redis нет, можно использовать заглушку (fake Redis)
  require 'fakeredis' unless ENV['USE_REAL_REDIS']
  $redis = if ENV['USE_REAL_REDIS']
    Redis.new(url: ENV.fetch('REDIS_URL') { 'redis://localhost:6379/1' })
  else
    FakeRedis::Redis.new
  end
end
