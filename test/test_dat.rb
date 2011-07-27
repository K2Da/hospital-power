# coding: UTF-8
gem "test-unit"
require "test/unit"
require "./src/DB.rb"
require "./src/TchThread.rb"
require "./src/Dat.rb"

class TC_Dat < Test::Unit::TestCase
  def setup
  end

  def teardown
  end

  def test_suject
    lines = File.open("./test/subject.txt", "r:Shift_JIS").read.encode(
              "UTF-8", "Shift_JIS", :invalid => :replace, :undef => :replace
            )
    $obj = Dat.current_threads(lines)

    assert_equal(14, $obj.length)
    assert_equal("1310855397", $obj[0][:no])
    assert_equal("1275710586", $obj[13][:no])
  end

  def test_thread_info
    $obj = Dat.thread_info("1308147249.dat<>threadname (330)")

    assert_equal("1308147249", $obj[:no])
    assert_equal("threadname", $obj[:name])
    assert_equal(330, $obj[:count])
  end
end
