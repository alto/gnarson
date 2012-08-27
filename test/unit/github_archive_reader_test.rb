require 'test_helper'

class GithubArchiveReaderTest < ActiveSupport::TestCase

  context 'iterating over the events' do
    setup do
      @reader = GithubArchiveReader.new(2012,8,27,1)
      @reader.stubs(:retrieve_json).returns(TestData.load('json/some_events.json'))
    end

    should 'succeed' do
      events = []
      @reader.each {|event| events << event['type']}
      assert_equal %w(PushEvent CreateEvent), events
    end
  end

end
