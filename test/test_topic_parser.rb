require 'stomp_server/topic_parser'
require 'test/unit'
require 'fileutils'

class TestTopicParsers < Test::Unit::TestCase

  def setup
    @tp = StompServer::TopicParser 
  end
  def test_truth
    assert_equal(true,true)
  end
end

