require 'open-uri'
require 'yajl'
module Tasks
  class EventLoader < Base
    class << self

      def update_events(from=7.days.ago.to_date, to=Date.yesterday)
        (from..to).each do |date|
          log "processing #{date2key(date)}"

          24.times.each do |hour|
            # puts "doing hour #{hour}"
            fetched = Gnarson.redis.get("#{Rails.env}:github:fetched:#{date2key(date)}")
            # puts "fetched = #{fetched}"
            if !fetched || (fetched.to_i - 1) < hour
              fetch_and_extract(date, hour)
              # puts "fetch_and_extract(#{date}, #{hour}"
              Gnarson.redis.incr("#{Rails.env}:github:fetched:#{date2key(date)}")
            else
              log "  already got data for #{date2key(date)}-#{hour}"
            end
          end

          log "finished #{date2key(date)}"
        end
      end

      def reset_events(from=7.days.ago.to_date, to=Date.yesterday)
        (from..to).each do |date|
          Gnarson.redis.keys("#{Rails.env}:github:*:#{date2key(date)}*").each do |key|
            Gnarson.redis.del(key)
          end
        end
      end

    private

      def date2key(date)
        date.strftime('%Y-%m-%d')
      end

      def fetch_and_extract(date, hour)
        # puts "fetch_and_extract(#{date}, #{hour})"
        log "  processing hour #{hour}"
        reader = GithubArchiveReader.new(date.year, date.month, date.day, hour)
        # gz = open("http://data.githubarchive.org/#{date2key(date)}-#{hour}.json.gz")
        # js = Zlib::GzipReader.new(gz).read
        # log "    fetched file"

        i = 0
        stop_at = nil

        types = {}
        repos = {}
        watches = {}

        reader.each do |event|
        # Yajl::Parser.parse(js) do |event|
          break if stop_at && i > stop_at

          # puts event.class # a Hash

          # count processed items
          Gnarson.redis.incr("#{Rails.env}:github:items:#{date2key(date)}")
          Gnarson.redis.incr("#{Rails.env}:github:items:#{date2key(date)}-#{hour}")

          # count types
          Gnarson.redis.incr("#{Rails.env}:github:types:#{event['type']}:#{date2key(date)}")

          case event['type']
          when 'PushEvent'
            # Worms::PushEventWorm.read(event, date)
            if event['repository']
              key = "#{event['repository']['owner']}/#{event['repository']['name']}"
              Gnarson.redis.incr("#{Rails.env}:github:repos:#{key}:#{date2key(date)}")
            else
              puts "PushEvent didn't contain a repository: #{event.inspect}"
            end
          when 'WatchEvent'
            if event['repository']
              key = "#{event['repository']['owner']}/#{event['repository']['name']}"
              Gnarson.redis.incr("#{Rails.env}:github:watches:#{key}:#{date2key(date)}")
            else
              puts "WatchEvent didn't contain a repository: #{event.inspect}"
            end
          end

          i += 1
        end
        log "    parsed file"
      end

    end # class << self
  end
end
