# coding: UTF-8
gem "test-unit"
require "test/unit"
require "./src/TchThread.rb"
require "./src/ViewThread.rb"

class TC_TchThreadManager < Test::Unit::TestCase
  def test_update
    tm = TchThreadManager.new
    assert(tm.years.length != 0, "year")
    assert(tm.months.length != 0, "month")
    assert(tm.days.length != 0, "days")
  end
end

class TC_TchThread < Test::Unit::TestCase
  def test_henfile
  end

  def test_initialize
  end
end

class TC_TchRes < Test::Unit::TestCase
  def test_foo
    checkline(
    '', 'フェンリル </b>◆BExFEN/FD. <b><><>2011/07/20(水) 21:10:36.74 ID:TEtgGXwr0 BE:1087796276-2BP(1000)<> ここ売名スレか <br> おーい俺NSBに出してくれー<>',
    'フェンリル /b◆BExFEN/FD. b', '', '2011-07-20 21:10:36', "2011/07/20(水)", "21:10:36", "TEtgGXwr0", "ここ売名スレか <br> おーい俺NSBに出してくれー")

    checkline(
      "", "名無し＠どこ<><>2011/06/12(日) 12:01:43.69 ID:+cuvQ7aF0<> やっ ぱ荒れてるなー。<>",
      "名無し＠どこ", "", "2011-06-12 12:01:43", "2011/06/12(日)", "12:01:43", "+cuvQ7aF0",
      "やっ ぱ荒れてるなー。")
    checkline(
      "", "俺より<>sage<>2011/03/07(月) 20:34:08.68 ID:pQUFvR4e0<> ここは<>sako応援>ス レッド 7hits",
      "俺より", "sage", "2011-03-07 20:34:08", "2011/03/07(月)", "20:34:08", "pQUFvR4e0",
      "ここは")
    checkline(
      "", '_<>sage　SI 7-5 EG<>2011/06/03(金) 14:41:31.05 ID:NOPn7DtN0<> <a target=\"_\">3</a><br> 眼<>',
      "_", "sage　SI 7-5 EG", "2011-06-03 14:41:31", "2011/06/03(金)", "14:41:31", "NOPn7DtN0",
      '<a target=\"_\">3</a><br> 眼')
  end

  def checkline(thread, line, name, email, date, ddate, dtime, id, text)
    @obj = TchRes.new(thread, 0, line, "")

    assert_equal(name, @obj.name)
    assert_equal(email, @obj.email)
    assert_equal(date, @obj.time.strftime("%Y-%m-%d %H:%M:%S"))


    assert_equal(id, @obj.id)
    assert_equal(text, @obj.text)

    v = ViewRes.new(nil, @obj)
    assert_equal(ddate, v.displaydate)
    assert_equal(dtime , v.displaytime)
  end
end
