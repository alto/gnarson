require 'open-uri'
require 'zlib'
require 'yajl'
require 'redis'

redis = Redis.new

gz = open("http://data.githubarchive.org/2012-07-26-1.json.gz")
js = Zlib::GzipReader.new(gz).read

i = 0; stop_at = 10000

types = {}
repos = {}
watches = {}

Yajl::Parser.parse(js) do |event|
  break if i > stop_at

  # puts event.inspect

  # count types
  redis.incr("github:types:#{event['type']}:2012-07-16")

  # analyse PushEvents
  if event['type'] == 'PushEvent'
    key = "#{event['repository']['owner']}/#{event['repository']['name']}"
    redis.incr("github:repos:#{key}:2012-07-16")
  end

  # analyse WatchEvents
  if event['type'] == 'WatchEvent'
    key = "#{event['repository']['owner']}/#{event['repository']['name']}"
    redis.incr("github:watches:#{key}:2012-07-16")
  end

  i += 1
end

redis.keys("github:*").each do |key|
  puts "#{redis.get(key)} x #{key}"
end
