require 'open-uri'
require 'zlib'
require 'yajl'

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
  types[event['type']] ||= 0
  types[event['type']] += 1
  # puts event['type']

  # analyse PushEvents
  if event['type'] == 'PushEvent'
    key = "#{event['repository']['owner']}/#{event['repository']['name']}"
    repos[key] ||= 0
    repos[key] += 1
  end

  # analyse WatchEvents
  if event['type'] == 'WatchEvent'
    key = "#{event['repository']['owner']}/#{event['repository']['name']}"
    watches[key] ||= 0
    watches[key] += 1
  end

  i += 1
end

# types.keys.each do |key|
#   puts "#{types[key]} x #{key}"
# end
# repos.keys.each do |key|
#   puts "#{repos[key]} x #{key}"
# end
watches.keys.each do |key|
  puts "#{watches[key]} x #{key}"
end
