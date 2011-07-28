# coding: UTF-8
gem "test-unit"
require "mysql"
require "test/unit"
require "./src/DB.rb"
require "./src/TchThread.rb"

class TC_DBThread < Test::Unit::TestCase
  def setup
    # DB.create_thread_table
    # THR.truncate
  end

  def test_info
    assert(THR.info.count != 0, "count")
  end

  def test_newer
    assert(THR.newer('2020').count == 0, "count")
    assert(THR.newer(Time.now - 10 * 60 * 60 *24).count != 0, "count")
  end
end
