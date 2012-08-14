require 'open-uri'
require 'yajl'
module Tasks
  class EventLoader < Base
    class << self
      
      def update_events(from=7.days.ago.to_date, to=Date.yesterday)
        (from..to).each do |date|
          log "processing #{date2key(date)}"

          24.times.each do |hour|
            fetched = Gnarson.redis.get("github:fetched:#{date2key(date)}")
            if !fetched || fetched.to_i < hour
              fetch_and_extract(date, hour)
              # puts "fetch_and_extract(#{date}, #{hour}"
              Gnarson.redis.incr("github:fetched:#{date2key(date)}")
            else
              log "  already got data for #{date2key(date)}-#{hour}"
            end
          end

          log "finished #{date2key(date)}"
        end
      end

      def reset_events(from=7.days.ago.to_date, to=Date.yesterday)
        (from..to).each do |date|
          Gnarson.redis.del("github:fetched:#{date2key(date)}")
          log "reset github:fetched:#{date2key(date)}"
        end
      end

    private

      def date2key(date)
        date.strftime('%Y-%m-%d')
      end

      def fetch_and_extract(date, hour)
        log "  processing hour #{hour}"
        gz = open("http://data.githubarchive.org/#{date2key(date)}-#{hour}.json.gz")
        js = Zlib::GzipReader.new(gz).read
        log "    fetched file"

        i = 0
        stop_at = nil

        types = {}
        repos = {}
        watches = {}

        Yajl::Parser.parse(js) do |event|
          break if stop_at && i > stop_at

          # puts event.inspect

          # count processed items
          Gnarson.redis.incr("github:items:#{date2key(date)}")
          Gnarson.redis.incr("github:items:#{date2key(date)}-#{hour}")

          # count types
          Gnarson.redis.incr("github:types:#{event['type']}:#{date2key(date)}")

          # analyse PushEvents
          if event['type'] == 'PushEvent'
            key = "#{event['repository']['owner']}/#{event['repository']['name']}"
            Gnarson.redis.incr("github:repos:#{key}:#{date2key(date)}")
          end

          # analyse WatchEvents
          if event['type'] == 'WatchEvent'
            key = "#{event['repository']['owner']}/#{event['repository']['name']}"
            Gnarson.redis.incr("github:watches:#{key}:#{date2key(date)}")
          end

          i += 1
        end        
        log "    parsed file"
      end

    end # class << self
  end
end
