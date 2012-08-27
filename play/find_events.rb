require 'open-uri'
require 'zlib'
require 'yajl'

KNOWN_EVENTS = %w(GollumEvent PushEvent IssuesEvent IssueCommentEvent WatchEvent ForkEvent CreateEvent DownloadEvent GistEvent FollowEvent CommitCommentEvent MemberEvent PublicEvent PullRequestReviewCommentEvent DeleteEvent PullRequestEvent)

#
# usage: ruby play/find_events.rb 2012-08-26
#
date = ARGV[0]
date ||= "2012-07-26"
24.times.each do |hour|
  puts "processing date #{date}, hour #{hour}"
  gz = open("http://data.githubarchive.org/#{date}-#{hour}.json.gz")
  js = Zlib::GzipReader.new(gz).read
  puts "  fetched file"

  i = 0; stop_at = 100000

  types = {}
  
  Yajl::Parser.parse(js) do |event|
    break if i > stop_at
    next if KNOWN_EVENTS.include?(event['type'])
    next if types.key?(event['type'])

    puts "found new event type #{event['type']}"
    puts event.inspect
    types[event['type']] = true

    i += 1
  end
end
