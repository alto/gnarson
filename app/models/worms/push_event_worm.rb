module Worms
  class PushEventWorm < Base

    def self.read(event, date) # hash, date
      key = "#{event['repository']['owner']}/#{event['repository']['name']}"
      Gnarson.redis.incr("#{Rails.env}:github:push:#{key}:#{date2key(date)}")
    end

  end
end
