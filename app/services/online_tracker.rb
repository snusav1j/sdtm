class OnlineTracker
  ONLINE_USERS_KEY = "online_users".freeze
  TIMEOUT = 2.minutes

  def self.mark_online(user_id)
    Redis.current.hset(ONLINE_USERS_KEY, user_id, Time.current.to_i)
  end

  def self.mark_offline(user_id)
    Redis.current.hdel(ONLINE_USERS_KEY, user_id)
  end

  def self.online?(user_id)
    last_seen = Redis.current.hget(ONLINE_USERS_KEY, user_id)
    last_seen && Time.at(last_seen.to_i) > TIMEOUT.ago
  end

  def self.all_online_user_ids
    Redis.current.hkeys(ONLINE_USERS_KEY).map(&:to_i)
  end
end
