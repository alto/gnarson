require 'test_helper'

class Worms::WatchEventWormTest < ActiveSupport::TestCase

  context :read do
    should 'store the stuff' do
      key = "test:github:watches:rsms/kod:2012-09-26"
      assert_difference "Gnarson.redis.get('#{key}').to_i", 1 do
        event = Worms::WatchEventWorm.read(TestData.load_event(:watch_event), Date.new(2012,9,26))
      end
    end
  end

end
