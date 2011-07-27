# coding: UTF-8
gem "test-unit"
require "test/unit"
require "./src/PageCache.rb"

class TC_PageCache < Test::Unit::TestCase
  def test_update
    obj = PageCache.new(4, 2)

    assert_equal(obj["u1"], nil)

    obj["u1"] = "h1"
    assert_equal(obj["u1"][:html], "h1")
    assert_equal(obj["u1"][:count], 2)
    assert_equal(obj["u1"][:count], 3)

    obj["u2"] = "h2"
    obj["u3"] = "h3"
    obj["u4"] = "h4"

    assert_equal(obj["u1"][:html], "h1")
    assert_equal(obj["u2"], nil)
    assert_equal(obj["u3"], nil)
    assert_equal(obj["u4"][:html], "h4")
    assert_equal(obj.pages.count, 2)

    obj["u5"] = "h5"
    assert_equal(obj["u5"][:html], "h5")
    assert_equal(obj.pages.count, 3)
  end
end
