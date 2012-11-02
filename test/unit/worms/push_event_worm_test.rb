require 'test_helper'

class Worms::PushEventWormTest < ActiveSupport::TestCase

  context :read do
    should 'store the stuff' do
      key = "test:github:repos:IVPR/Weave-Binaries:2012-09-26"
      assert_difference "Gnarson.redis.get('#{key}').to_i", 1 do
        event = Worms::PushEventWorm.read(TestData.load_event(:push_event), Date.new(2012,9,26))
      end
    end
  end

end
