module Worms
  class WatchEventWorm < Base

    def self.read(event, date) # hash, date
      if event['repository']
        key = "#{event['repository']['owner']}/#{event['repository']['name']}"
        Gnarson.redis.incr("#{Rails.env}:github:watches:#{key}:#{date2key(date)}")
      else
        puts "WatchEvent didn't contain a repository: #{event.inspect}"
      end
    end

  end
end
