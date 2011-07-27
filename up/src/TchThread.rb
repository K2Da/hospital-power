# coding: UTF-8
require './src/Dat.rb'
require './src/DB.rb'
require './src/Common.rb'

class TchThreadManager
  attr_accessor :updatedat
  attr_reader   :years, :months, :days

  UPDATE_SPAN = 10 * 60

  def initialize
    @threads = {}
    @updatedat = Time.now - UPDATE_SPAN

    THR.all.each { |t|
      @threads[t[:no]] = TchThread.new(t[:no], t[:dat].force_encoding('Shift_JIS'))
    }
    update_calendar
  end

  def update
    return if Time.now.to_jst < @updatedat + UPDATE_SPAN || ENV['HOSPITALPWR_CACHE_MODE'] == "1"
    Dat.current_threads.each { |t|
      no = t[:no].to_i
      if @threads[no] == nil ||
        t[:count] > @threads[no].res.length &&  @threads[no].res.length != 1000

        p "get dat dat length = " + t[:count].to_s
        p "memory res length" + @threads[no].res.length.to_s if @threads[no] != nil

        d = Dat.get_thread(t[:no])
        n = TchThread.new(t[:no], d)
        THR.delete(n)
        THR.insert(n, d)
        @threads[no] = n
      end
    }
    @updatedat = Time.now.to_jst
    update_calendar
  end

  def all
    @threads
  end

  def update_calendar
    @years, @months, @days = {}, {}, {}
    @threads.each { |n, t|
      d, y, m = t.from.to_date, nil, nil

      until d > t.to.to_date
        if y != d.to_year
          y = d.to_year
          @years[y] == nil ? @years[y] = 1 : @years[y] += 1
        end

        if m != d.to_month
          m = d.to_month
          @months[m] == nil ? @months[m] = 1 : @months[m] += 1
        end

        @days[d] == nil ? @days[d] = 1 : @days[d] += 1

        d += 60 * 60 * 24
      end
    }
  end
end

class TchThread
  attr_accessor :no, :title, :res

  # initialize from dat file
  def initialize(no, dat)
    @no, @res, @title, i = no, Array.new, "", 1

    dat.encode(
      "UTF-8", "Shift_JIS", :invalid => :replace, :undef => :replace
      ).split("\n").each_with_index { |l, i|
      @res << TchRes.new(self, i + 1, l, i == 0 ? title : "") if i < 1000
    }

    set_refer
  end

  def from; @res[0].time; end

  def to; @res.last.time; end

  REG_REF = /<a href=\"\S+\" target=\"_blank\">\&gt;\&gt;(\d+)<\/a>(.*)/u

  def set_refer
    res.each do |r|
      t = r.text
      while m = REG_REF.match(t) do
	r.add_refer_to(res_by_no(m.captures[0].to_i))
	t = m.captures[1]
      end
    end
    res.each { |r| r.text_replace }
  end

  def res_by_no(no); @res.find { |r| r.no == no }; end
end

class TchRes
  attr_accessor :thread, :no, :name, :email, :time, :id, :text, :refer_to, :refer_from

  REG_RES = /(.*)<>(.*)<>(.*?) ID\:(\S*)(?: BE:\S*){0,1}<> (.*)<>(.*)$/u
  REG_DAY = /(\d+)\/(\d+)\/(\d+)\(.\) (\d+)\:(\d+)\:(\d+).*/u

  # initialize by dat file
  def initialize(thread, no, dat_line, title)
    begin
      m = REG_RES.match(dat_line.strip).captures
      @thread, @no, @name, @email, @id, @text = thread, no, m[0].delete("<>"), m[1].delete("<>"), m[3], m[4]
      title.replace(m[5])

      n = REG_DAY.match(m[2]).captures
      @time = Time.local(n[0], n[1], n[2], n[3], n[4], n[5], n[6])
      @refer_to, @refer_from = Array.new, Array.new
    rescue => ex
      p "thread no:" + thread.no.to_s + " res no:" + no.to_s
      p ex
    end
  end

  def add_refer_to(ref)
    return if ref == nil
    @refer_to << ref
    ref.refer_from << self
  end

  def text_replace
    @text = @text.gsub(
      /<a href="\S+" target="_blank">&gt;&gt;(\d+)<\/a>/,
      '<a href="#' + @thread.no.to_s + '_\1">&gt;&gt;\1</a>'
    )
  end
end
