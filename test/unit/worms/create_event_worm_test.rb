require 'test_helper'

class Worms::CreateEventWormTest < ActiveSupport::TestCase

  context :read do
    should 'store the stuff' do
      key = "test:github:create:kkz-yk/myApp:2012-09-26"
      assert_difference "Gnarson.redis.get('#{key}').to_i", 1 do
        event = Worms::CreateEventWorm.read(TestData.load_event(:create_event), Date.new(2012,9,26))
      end
    end
  end

end
