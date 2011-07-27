# coding: UTF-8
require './src/TchThread.rb'
require './src/ViewThread.rb'
require './src/config.rb'

class DailyInfoManager
  @@cache = {}
  
  def DailyInfoManager.[](day)
    if @@cache[day] == nil || (
         @@cache[day][:time].to_day_link == day.to_day_link &&
         @@cache[day][:time] < TM.updatedat 
       )
      @@cache[day] = { :time => Time.now.to_jst, :info => DailyInfo.new(day) }
    end

    return @@cache[day][:info]
  end
end

class DailyInfo 
  attr_reader :count, :hours_link, :id_link, :player_link
  ID_LINK_COUNT     = 10
  PLAYER_LINK_COUNT = 100

  ##########
  # initialize
  ##########
  def initialize(day)
    @day = day
    @vt = ViewThread.new( { :date => day, :daily_info => true } )
    collect_values
  end

  def collect_values
    @count, @id, @player = 0, {}, {}

    initialize_time_span

    @vt.all.each do |res|
      if res.interm
        @count += 1
        set_time_span(res)
        set_id(res)
        set_player(res)
      end  
    end 

    set_hours_link
    set_id_link
    set_player_link
  end

  def initialize_time_span
    @timespan = {}
    d = @vt.from
    while d < @vt.to
      @timespan[d] = 0
      d += MAX_TIMESPAN
    end
    @timespan_keys = @timespan.keys.sort
  end

  def set_time_span(r)
    @timespan_keys.each_with_index { |t, i|
      if r.time < t
        @timespan[@timespan_keys[i - 1]] += 1
        return
      end
    }
    @timespan[@timespan_keys[-1]] += 1
  end

  def set_id(r)
    @id[r.id] == nil ? @id[r.id] = 1 : @id[r.id] += 1
  end

  def set_player(r)
    PLAYERS.each { |p, reg|
      if reg === r.text
        @player[p] == nil ? @player[p] = 1 : @player[p] += 1
      end
    }
  end

  ##########
  # for disiplay
  ##########
  def set_hours_link
    ret = ""
    @timespan.each { |hour, count|
      ret << '<a href="' + hour.to_link + '">' + hour.strftime("%H:%M") + '</a>' +
             '(' + count.to_s + "), " if count > 0
    }
    @hours_link = ret[0..-3]
  end

  def set_id_link
    ret = ""
    @id.sort { |a, b| b[1] - a[1] }.each_with_index { |kv, i|
      break if i >= ID_LINK_COUNT
      ret << '<a href="' + @day.to_day_link + "id/" + kv[0].gsub('+', '%2b') + '/">' + kv[0] + '</a>' +
             '(' + kv[1].to_s + "), "
    }
    @id_link = ret[0..-3]
  end

  def set_player_link
    ret = ""
    @player.sort { |a, b| b[1] - a[1] }.each_with_index { |kv, i|
      break if i >= PLAYER_LINK_COUNT
      ret << '<a href="' + @day.to_day_link + "player/" + kv[0].to_s + '/">' + kv[0].to_s + '</a>' +
             '(' + kv[1].to_s + "), "
    }
    @player_link = ret[0..-3]
  end

  def id_count
    return @id.count
  end
end
