require 'test_helper'

class Tasks::EventLoaderTest < ActiveSupport::TestCase

  context :update_events do
    setup do
      Tasks::EventLoader.reset_events(Date.new(2012,1,1), Date.new(2012,1,1))
      FakeWeb.register_githubarchive('2012-01-01', :file => 'githubarchive/some_events.json.gz')
    end

    # everything is a multiple of 24, because we return the same events for all 24 hours
    should 'work' do
      Tasks::EventLoader.update_events(Date.new(2012,1,1), Date.new(2012,1,1))

      num_events = 4
      assert_equal 24 * num_events, Gnarson.redis.get('test:github:items:2012-01-01').to_i
      assert_equal      num_events, Gnarson.redis.get('test:github:items:2012-01-01-0').to_i
      assert_equal      num_events, Gnarson.redis.get('test:github:items:2012-01-01-23').to_i

      assert_equal 24, Gnarson.redis.get('test:github:types:PushEvent:2012-01-01').to_i
      assert_equal 24, Gnarson.redis.get('test:github:types:CreateEvent:2012-01-01').to_i
      assert_equal 24, Gnarson.redis.get('test:github:types:WatchEvent:2012-01-01').to_i
      assert_equal 24, Gnarson.redis.get('test:github:types:CommitCommentEvent:2012-01-01').to_i

      assert_equal 24, Gnarson.redis.get('test:github:push:begoon/begoon.github.com:2012-01-01').to_i
      assert_equal 24, Gnarson.redis.get('test:github:create:kkz-yk/myApp:2012-01-01').to_i
      assert_equal 24, Gnarson.redis.get('test:github:watch:rsms/kod:2012-01-01').to_i
      assert_equal 24, Gnarson.redis.get('test:github:commit_comment:ktei/gitcode:2012-01-01').to_i
    end

  end

end
