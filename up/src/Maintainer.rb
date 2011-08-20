# coding: UTF-8
require './src/TchThread.rb'
require './src/DailyInfo.rb'

class Maintainer
  UPDATE_SPAN = 2 * 60
  def initialize
    @last = nil
  end

  def start
    t = Thread.new do
      loop
    end
    t.priority = -1
  end

  def loop
    while true
      begin
        sleep 10
        
        n = Time.now.to_jst
        if @last == nil || (@last < n - UPDATE_SPAN && n.min % 10 == 0)
          maintain(n)
          @last = n
        end
      rescue => err
        p err
        p err.backtrace
      end
    end
  end

  def maintain(n)
    p n
    p "--------------------------------------------------------------"
    TM.update

    DailyInfoManager.renew(n.to_date)
    DailyInfoManager.renew((n - 1 * 60 * 60 * 24).to_date) if n.hour == 0 && n.min / 10 == 0
    DailyInfoManager.create_cache
    GC.start
  end
end
