# coding: UTF-8
require 'strscan'
require './src/TchThread.rb'
require './src/ViewThread.rb'
require './src/config.rb'

class DailyInfoManager
  @@cache = {}
  
  def DailyInfoManager.[](day)
    if @@cache[day] == nil
      @@cache[day] = { :time => Time.now.to_jst, :info => DailyInfo.new(day) }
    end

    return @@cache[day][:info]
  end

  def DailyInfoManager.renew(day)
    @@cache[day] = { :time => Time.now.to_jst, :info => DailyInfo.new(day) }
  end

  def DailyInfoManager.all
    @@cache
  end
end

class DailyInfo 
  attr_reader :count, :id

  ##########
  # initialize
  ##########
  def initialize(day)
    @day, @count, @id, @player, @link = day, 0, {}, {}, {}
    vt = ViewThread.new( { :date => day, :daily_info => true } )
    collect_values(vt)
    p "Daily info for " + day.to_short_str
  end

  def collect_values(vt)
    initialize_time_span(vt)

    vt.all.each do |res|
      if res.interm
        @count += 1
        set_time_span(res)
        set_id(res)
        set_player(res)
      end  
    end 
  end

  def initialize_time_span(vt)
    @timespan = {}
    d = vt.from
    while d < vt.to
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
    link_player = []

    PLAYERS.each { |p, reg|
      if reg === r.text
        @player[p] == nil ? @player[p] = 1 : @player[p] += 1
        link_player << p.to_s
      end
    }

    s = StringScanner.new(r.text)
    until s.eos?
      case
      when s.scan_until(/ttp:\S+/)
        l = "h" + s[0]
        if @link[l] == nil
          @link[l] = {
            :player => [],
            :res    => []
          } 
        end

        @link[l][:player] = @link[l][:player] | link_player
        @link[l][:res]    = @link[l][:res] | [r]
      else
        break
      end
    end
  end

  ##########
  # for disiplay
  ##########
  def hours_link
    ret = ""
    @timespan.each { |hour, count|
      ret <<
        '<a href="' + hour.to_link + '">' + hour.strftime("%H") + '</a>' +
        '(' + count.to_s + "), " if count > 0
    }
    ret[0..-3]
  end

  def id_link(no)
    ret = ""
    @id.sort { |a, b| b[1] - a[1] }.each_with_index { |kv, i|
      break if i >= no
      ret <<
        '<a href="' + @day.to_day_link + "id/" + kv[0].gsub('+', '%2b') + '/">' +
        kv[0] + '</a>' + '(' + kv[1].to_s + "), "
    }
    ret[0..-3]
  end

  def player_link(no)
    ret = ""
    @player.sort { |a, b| b[1] - a[1] }.each_with_index { |kv, i|
      break if i >= no
      ret <<
        '<a href="' + @day.to_day_link + "player/" + kv[0].to_s + '/">' +
        kv[0].to_s + '</a>' + '(' + kv[1].to_s + "), "
    }
    ret[0..-3]
  end

  def link_link(no)
    ret = '<dl>'
    @link.sort { |a, b|
      b[1][:res].inject(0) { |b, i| b + i.refer_from.length } -
      a[1][:res].inject(0) { |b, i| b + i.refer_from.length }
    }.each_with_index { |kv, i|
      break if i >= no
      ret << '<dt>'
      count = kv[1][:res].inject(0) { |b, i| b + i.refer_from.length }
      ret << '[' + count.to_s + '] '

      kv[1][:player].each { |p| ret << p.to_s + ", " }
      ret << "- " if kv[1][:player].length == 0
      kv[1][:res].each { |r|
        ret <<
          "<a href='/thread/" + r.thread.no.to_s + "/res/" + r.no.to_s + "/'>" +
          r.time.strftime("%H") + "</a>(" + r.refer_from.length.to_s + ") "
      }
      ret << '</dt>'
      ret << '<dd><a href="' + kv[0] + '">' + kv[0] + '</a></dd>'
    }
    ret << '</dl>'
    ret
  end
end
