# coding: UTF-8
gem "test-unit"
require "mysql"
require "test/unit"
require "./src/DB.rb"
require "./src/TchThread.rb"

Lines1 = File.open("../test/1299497648.dat", "r:Shift_JIS").read
Lines2 = File.open("../test/1310695489.dat", "r:Shift_JIS").read

class TC_DBThread < Test::Unit::TestCase
  def setup
    DB.create_thread_table
    THR.truncate
  end

  def test_insert
    tt1 = TchThread.new(1299497648, Lines1)
    tt2 = TchThread.new(1310695489, Lines2)

    THR.insert(tt1, Lines1)
    THR.insert(tt2, Lines2)
    assert_equal(2, THR.count)

    threads = []
    THR.all.each { |t|
      threads << TchThread.new(t[:no], t[:dat].force_encoding('Shift_JIS'))
    }
    assert_equal(2, threads.length)
    assert_equal(tt1.no, THR.all[0][:no])
    assert_equal(Lines1, THR.all[0][:dat].force_encoding("Shift_JIS"))
    assert_equal(Lines2, THR.all[1][:dat].force_encoding("Shift_JIS"))
  end
end
