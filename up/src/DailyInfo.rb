# coding: UTF-8
require 'strscan'
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
  attr_reader :count, :id_count, :hours_link, :id_link, :player_link, :link_link
  ID_LINK_COUNT     = 10
  PLAYER_LINK_COUNT = 100
  LINK_LINK_COUNT   = 10 

  ##########
  # initialize
  ##########
  def initialize(day)
    @day = day
    vt = ViewThread.new( { :date => day, :daily_info => true } )
    collect_values(vt)
  end

  def collect_values(vt)
    @count, id, player, link = 0, {}, {}, {}

    initialize_time_span(vt)

    vt.all.each do |res|
      if res.interm
        @count += 1
        set_time_span(res)
        set_id(id, res)
        set_player(player, link, res)
      end  
    end 

    @id_count = id.count

    set_hours_link
    set_id_link(id)
    set_player_link(player)
    set_link_link(link)
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

  def set_id(id, r)
    id[r.id] == nil ? id[r.id] = 1 : id[r.id] += 1
  end

  def set_player(player, link, r)
    link_player = []

    PLAYERS.each { |p, reg|
      if reg === r.text
        player[p] == nil ? player[p] = 1 : player[p] += 1
        link_player << p.to_s
      end
    }

    s = StringScanner.new(r.text)
    until s.eos?
      case
      when s.scan_until(/ttp:\S+/)
        l = "h" + s[0]
        if link[l] == nil
          link[l] = {
            :player => [],
            :res    => []
          } 
        end

        link[l][:player] = link[l][:player] | link_player
        link[l][:res]    = link[l][:res] | [r]
      else
        break
      end
    end
  end

  ##########
  # for disiplay
  ##########
  def set_hours_link
    ret = ""
    @timespan.each { |hour, count|
      ret <<
        '<a href="' + hour.to_link + '">' + hour.strftime("%H") + '</a>' +
        '(' + count.to_s + "), " if count > 0
    }
    @hours_link = ret[0..-3]
  end

  def set_id_link(id)
    ret = ""
    id.sort { |a, b| b[1] - a[1] }.each_with_index { |kv, i|
      break if i >= ID_LINK_COUNT
      ret <<
        '<a href="' + @day.to_day_link + "id/" + kv[0].gsub('+', '%2b') + '/">' +
        kv[0] + '</a>' + '(' + kv[1].to_s + "), "
    }
    @id_link = ret[0..-3]
  end

  def set_player_link(player)
    ret = ""
    player.sort { |a, b| b[1] - a[1] }.each_with_index { |kv, i|
      break if i >= PLAYER_LINK_COUNT
      ret <<
        '<a href="' + @day.to_day_link + "player/" + kv[0].to_s + '/">' +
        kv[0].to_s + '</a>' + '(' + kv[1].to_s + "), "
    }
    @player_link = ret[0..-3]
  end

  def set_link_link(link)
    ret = '<dl>'
    link.sort { |a, b|
      b[1][:res].inject(0) { |b, i| b + i.refer_from.length } -
      a[1][:res].inject(0) { |b, i| b + i.refer_from.length }
    }.each_with_index { |kv, i|
      break if i >= LINK_LINK_COUNT
      ret << '<dt>'
      kv[1][:player].each { |p| ret << p.to_s + ", " }
      ret << " - " if kv[1][:player].length == 0
      kv[1][:res].each { |r|
        ret <<
          "<a href='/thread/" + r.thread.no.to_s + "/res/" + r.no.to_s + "/'>" +
          r.time.strftime("%H") + "</a>(" + r.refer_from.length.to_s + ") "
      }
      ret << '</dt>'
      ret << '<dd>'
      break if i >= LINK_LINK_COUNT
      ret << (
        '<a href="' + kv[0] + '">' + kv[0] + '</a>'
      )
      ret << '</dd>'
    }
    ret << '</dl>'
    @link_link = ret
  end
end
