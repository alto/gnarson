require 'open-uri'
require 'zlib'
require 'yajl'

class GithubArchiveReader

  def initialize(year, month, day, hour)
    @date = sprintf("%d-%02d-%d-%d", year, month, day, hour)
  end

  def each(&block)
    Yajl::Parser.parse(retrieve_json, &block)
  end

  def retrieve_json
    gz = open("http://data.githubarchive.org/#{@date}.json.gz")
    js = Zlib::GzipReader.new(gz).read
  end

end
