module Worms
  class CreateEventWorm < Base

    def self.read(event, date) # hash, date
      if event['repository']
        repo = "#{event['repository']['owner']}/#{event['repository']['name']}"
        key = "#{Rails.env}:github:create:#{repo}:#{date2key(date)}"
        Gnarson.redis.incr(key)
      else
        puts "CreateEvent didn't contain a repository: #{event.inspect}"
      end
    end

  end
end
