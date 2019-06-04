require "test_helper"

class KaomojiTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Kaomoji::VERSION
  end

  def test_puniu
    assert_equal ['(・3・)＼(^o^)／'], Kaomoji.get_unicode_kaomojis('(・3・)＼(^o^)／ぷにう')
  end
end
