module Gnarson
  def self.redis
    @redis ||= ::Redis.new(:host => 'localhost', :port => 6379)
  end
end
