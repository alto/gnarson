require 'test_helper'

class Worms::CommitCommentEventWormTest < ActiveSupport::TestCase

  context :read do
    should 'store the stuff' do
      key = "test:github:commit_comment:ktei/gitcode:2012-09-26"
      assert_difference "Gnarson.redis.get('#{key}').to_i", 1 do
        event = Worms::CommitCommentEventWorm.read(TestData.load_event(:commit_comment_event), Date.new(2012,9,26))
      end
    end
  end

end
