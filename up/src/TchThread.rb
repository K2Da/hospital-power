# coding: UTF-8
require './src/Dat.rb'
require './src/DB.rb'
require './src/Common.rb'

class TchThreadManager
  attr_accessor :updatedat
  attr_reader   :years, :months, :days

  UPDATE_SPAN = 10 * 60
  INITIAL_DAT = 3 * 60 * 60 * 24

  def initialize
    @threads = {}
    @updatedat = Time.now - UPDATE_SPAN

    THR.all.each { |t|
      @threads[t[:no]] = TchThread.new_db(t[:no], t[:title], t[:from], t[:to], t[:res_count])
    }

    THR.newer(Time.now.to_jst - INITIAL_DAT).each { |t|
      @threads[t[:no]] = TchThread.new_dat(t[:no], t[:dat])
    }

    update
  end

  def update
    return if Time.now.to_jst < @updatedat + UPDATE_SPAN || ENV['HOSPITALPWR_CACHE_MODE'] == "1"

    Dat.current_threads.each { |t|
      no = t[:no].to_i
      if @threads[no] == nil ||
        t[:count] > @threads[no].res_count &&  @threads[no].res_count != 1000

        p "get dat dat length = " + t[:count].to_s
        p "memory res length" + @threads[no].res_count.to_s if @threads[no] != nil

        d = Dat.get_thread(t[:no])
        n = TchThread.new_dat(t[:no], d)
        THR.delete(n)
        THR.insert(n, d)
        @threads[no] = n
      end
    }
    @threads.each { |no, thread| thread.delete_res }

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
  LIFETIME = 10 * 60
  attr_accessor :no, :title, :lastaccess, :res_count

  def initialize(no)
    @no = no
  end

  # initialize from dat file
  def self.new_dat(no, dat)
    p "thread new from dat:" + no.to_s
    obj = self.new(no)
    obj.title, i = "", 1
    obj.lastaccess = nil

    obj.res_from_dat(dat)

    obj
  end

  # initialize from db
  def self.new_db(no, title, from, to, res_count)
    p "thread new from db:" + no.to_s
    obj = self.new(no)
    obj.title, obj.from, obj.to, obj.res_count = title, from, to, res_count
    obj
  end

  def res_from_dat(dat)
    @res_arr = []
    lines = dat.encode(
      "UTF-8", "Shift_JIS", :invalid => :replace, :undef => :replace
      ).split("\n")

    lines.each_with_index { |l, i|
      if i < 1000
        r = TchRes.new(self, i + 1, l, i == 0 ? title : "")
        @res_arr << r if r.time != nil
      end
    }
    set_refer
    @from, @to, @res_count = from, to, lines.length
  end

  def from
    return @from if @res_arr == nil
    res[0].time
  end
  
  def from=(f)
    @from = f
  end

  def to
    return @to if @res_arr == nil
    res.last.time
  end

  def to=(t)
    @to = t
  end

  def res
    if @res_arr == nil 
      res_from_dat(THR.dat(@no)[:dat])
      p "get dat from db " + @no.to_s
    end

    @lastaccess = Time.now.to_jst
    @res_arr
  end

  def delete_res
    return if @res_arr == nil
    if @lastaccess == nil || @lastaccess < Time.now.to_jst - LIFETIME
      @res_arr = nil
      p "thread delete " + no.to_s
    end
  end

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

  def res_by_no(no); res.find { |r| r.no == no }; end
end

class TchRes
  attr_accessor :thread, :no, :name, :email, :time, :id, :text, :refer_to, :refer_from

  REG_RES = /(.*)<>(.*)<>(.*?) ID\:(\S*)(?: BE:\S*){0,1}<> (.*)<>(.*)$/u
  REG_DAY = /(\d+)\/(\d+)\/(\d+)\(.\) (\d+)\:(\d+)\:(\d+).*/u

  # initialize by dat file
  def initialize(thread, no, dat_line, title)
    @thread, @no = thread, no
    @name, @email, @id, @text = "", "", "", ""
    @time = nil
    begin
      m = REG_RES.match(dat_line.strip).captures
      @name, @email, @id, @text = m[0].delete("<>"), m[1].delete("<>"), m[3], m[4]
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

  def id_forjs
    @id.gsub('+', '_2b').gsub('/', '_2F')
  end
end
