# coding: UTF-8
require './src/TchThread.rb'

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
        if @last == nil || (@last < n - UPDATE_SPAN) && n.min % 10 == 0)
          maintain
          @last = n
        end
      rescue => err
        p err
      end
    end
  end

  def maintain
    p Time.now
    p "--------------------------------------------------------------"
    TM.update
  end
end
