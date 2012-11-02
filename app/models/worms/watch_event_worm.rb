module Worms
  class WatchEventWorm < Base

    def self.read(event, date) # hash, date
      if event['repository']
        repo = "#{event['repository']['owner']}/#{event['repository']['name']}"
        key = "#{Rails.env}:github:watch:#{repo}:#{date2key(date)}"
        Gnarson.redis.incr(key)
      else
        puts "WatchEvent didn't contain a repository: #{event.inspect}"
      end
    end

  end
end
