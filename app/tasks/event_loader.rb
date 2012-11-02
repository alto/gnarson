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

        i = 0
        stop_at = nil

        types = {}
        repos = {}
        watches = {}

        reader.each do |event|
          break if stop_at && i > stop_at

          # puts event.class # a Hash
          # puts event['type']

          # count processed items
          Gnarson.redis.incr("#{Rails.env}:github:items:#{date2key(date)}")
          Gnarson.redis.incr("#{Rails.env}:github:items:#{date2key(date)}-#{hour}")

          # count types
          Gnarson.redis.incr("#{Rails.env}:github:types:#{event['type']}:#{date2key(date)}")

          # TODO: do all this in parallel? (e.g. using Celluloid) [thorsten, 2012-11-02]
          case event['type']
          when 'PushEvent'
            Worms::PushEventWorm.read(event, date)
          when 'WatchEvent'
            Worms::WatchEventWorm.read(event, date)
          end

          i += 1
        end
        log "    parsed file"
      end

    end # class << self
  end
end
