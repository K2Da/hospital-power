# coding: UTF-8
require './src/TchThread.rb'
require 'delegate'

WEEKDAY = "日月火水木金土"

class ViewOneThread
  attr_reader :all, :conds

  def initialize(conds)
    @thread_no, @res, @res_from, @res_to, @conds =
      conds[:thread_no].to_i,
      conds[:res],
      conds[:res_from] == nil ? 1 : conds[:res_from].to_i,
      conds[:res_to]  == nil ? 1000 : conds[:res_to].to_i,
      conds
    @res_from, @res_to = @res.to_i, @res.to_i if @res != nil

    @thread = TM.all[@thread_no]
    @all = @thread.res.map! { |r| ViewRes.new(self, r) }.sort! { |r1, r2| r1.time - r2.time }

    set_term
    set_refer
  end

  def target_no
    @res_from == @res_to ? @res_from : nil
  end

  def crumb
    ret = "where thread == " + @thread_no.to_s
    if @res != nil
      ret << " and res == " + @res.to_s
    else
      ret << " and no > " + @res_from.to_s if @res_from != nil && @res_from != 1
      ret << " and no < " + @res_to .to_s if @res_to != nil && @res_to != 1000
    end
    ret
  end

  def res_by_conds
    @all
  end

  def set_term
    mode = :before
    @thread.res.each { |r|
      r.interm = false
      case mode
        when :before; mode, r.interm = :in, true if r.no >= @res_from
        when :in    ; r.no > @res_to ?  mode = :after : r.interm = true
        when :after
      end
    }
  end

  def set_refer
    @all.each { |r| r.set_refer() }
  end

  def next_link
    return ""
  end
end

class ViewThread
  attr_reader :all, :from, :to, :conds, :id, :player

  def initialize(conds)
    @conds, @player, @id = conds, conds[:player], conds[:id]
    @from, @to = ViewThread.check_time(conds)
    @real_threads = TM.all.values.find_all { |t| t.to > @from && t.from < @to }
    select_res
    set_term
    @all.each { |r| r.set_refer() }
  end

  def select_res
    already = []
    notyet  = []

    @real_threads.each { |rt| rt.res.each { |r| check_res(r, already, notyet) } }
    notyet.each { |ny| already << ny if res_check(ny, already, []) }
    @all = already.sort! { |r1, r2| r1.time - r2.time }.map! { |r| ViewRes.new(self, r) }
  end

  def check_res(r, already, notyet)
    if r.time > @from && r.time < @to &&
       (@id     == nil || @id == r.id) &&
       (@player == nil || PLAYERS[@player.to_sym] === r.text)
      already << r
    elsif r.refer_to.count != 0 || r.refer_from.count != 0
      notyet << r
    end
  end

  def res_check(r, already, checked)
    return true  if already.include?(r) 
    return false if checked.include?(r)
    checked << r
    
    r.refer_to.each   { |c| return true if res_check(c, already, checked) }
    r.refer_from.each { |c| return true if res_check(c, already, checked) }
    return false
  end

  def crumb
    (@from.to_day_crumb + " ") + 
    (@from.to_display_time != "00:00:00" ? "from "   + @from.to_display_time + ' '       : '') +
    (@id                   != nil        ? "where id == "     + @id.to_s + ' '           : '') +
    (@player               != nil        ? "where player == " + @player.to_s   + ' '     : '')
  end

  def res_by_conds
    @all
  end

  def set_term
    mode = :before

    @all.each { |r|
      r.interm = false
      case mode
        when :before; mode, r.interm = :in, true if r.time >= @from
        when :in    ; r.time > @to ?  mode = :after : r.interm = true
        when :after
      end
    }
  end

  def next_link
    if Time.now.to_jst.comparetime >= @to.comparetime
      @to.to_link
    elsif (last = @all.reverse.find { |r| r.displayed }) != nil
      last.time.to_link
    else
      @from.to_link
    end
  end

  ##########
  # class methods
  ##########
  def ViewThread.check_time(conds)
    d    = conds[:date]
    from = ViewThread.set_time_into_date(d, conds[:from])
    to   = ViewThread.set_time_into_date(d, conds[:to])
    ret_from, ret_to = nil, nil
    
    if conds[:daily_info]
      ret_from, ret_to = d, d + 24 * 60 * 60
    elsif conds[:id] != nil || conds[:player] != nil # no limit
      ret_from = from == nil ? d : from
      ret_to   = to   == nil ? d + 24 * 60 * 60 : to
    elsif from != nil && to != nil
      ret_from = from
      ret_to   = to - from < MAX_TIMESPAN ? to : from + MAX_TIMESPAN
    elsif from == nil && to != nil
      ret_from = to - MAX_TIMESPAN
      ret_to   = to
    elsif from != nil && to == nil
      ret_from = from
      ret_to   = from + MAX_TIMESPAN
    else
      ret_from, ret_to = d, d + MAX_TIMESPAN
    end
    return ret_from, ret_to
  end

  # date + "01:01:01" => new date
  def ViewThread.set_time_into_date(d, ts)
    return nil if ts == nil

    h, m, s = ts.split(':')
    Time.new(d.year, d.month, d.day, h.to_i, m.to_i, s.to_i)
  end
end

class ViewRes < DelegateClass(TchRes)
  attr_reader   :realres, :refer_to_view, :refer_from_view
  attr_accessor :interm, :displayed

  def initialize(vthread, res)
    super(res)
    @displayed, @vthread, @realres, @interm = false, vthread, res, true
  end

  def target_id
    @vthread.respond_to?(:id) && @vthread.id != nil && @vthread.id == @realres.id
  end

  def set_refer()
    @refer_to_view   = refer_to.map { |r| @vthread.all.find { |vr| vr.realres == r } }
    @refer_from_view = refer_from.map { |r| @vthread.all.find { |vr| vr.realres == r } }
  end

  def text
    return super if !@vthread.respond_to?(:player) || @vthread.player == nil
    super.gsub(PLAYERS[@vthread.player.to_sym]) { |p|
      '<span class="y">' + p + '</span>'
    }
  end

  def is_target_res?
    @vthread.respond_to?(:target_no) &&
      @vthread.target_no != nil &&
      @vthread.target_no == @realres.no
  end
end
