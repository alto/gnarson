require 'test_helper'

class Tasks::EventLoaderTest < ActiveSupport::TestCase

  context :update_events do
    setup do
      Tasks::EventLoader.reset_events(Date.new(2012,1,1), Date.new(2012,1,1))
      FakeWeb.register_githubarchive('2012-01-01', :file => 'githubarchive/some_events.json.gz')
    end

    should 'work' do
      Tasks::EventLoader.update_events(Date.new(2012,1,1), Date.new(2012,1,1))

      assert_equal 48, Gnarson.redis.get('test:github:items:2012-01-01').to_i
      assert_equal  2, Gnarson.redis.get('test:github:items:2012-01-01-0').to_i
      assert_equal 24, Gnarson.redis.get('test:github:types:PushEvent:2012-01-01').to_i
      assert_equal 24, Gnarson.redis.get('test:github:types:CreateEvent:2012-01-01').to_i
      assert_equal 24, Gnarson.redis.get('test:github:repos:begoon/begoon.github.com:2012-01-01').to_i
    end

  end

end
