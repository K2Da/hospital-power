# coding: UTF-8
require './src/ViewThread.rb'

class PageCache
  attr_reader :pages, :hit, :miss, :update

  def initialize(max, min)
    @max, @min, @pages   = max, min, {}
    @hit, @miss, @update = 0, 0, 0
  end

  def [](url)
    ret = @pages[url]
    if ret == nil
      @miss += 1
      return nil
    else
      @hit += 1
    end
    
    @pages[url] = {
      :html     => ret[:html],
      :lastused => Time.now.to_jst,
      :created  => ret[:created],
      :count    => ret[:count] + 1
    }
    return ret
  end

  def []=(url, html)
    @update += 1 if @pages[url] != nil

    @pages[url] = {
      :html     => html,
      :lastused => Time.now.to_jst,
      :created  => Time.now.to_jst,
      :count    => 1
    }
    cut_cache
  end
  
  def cut_cache
    return if @pages.count < @max

    new_pages = {}
    @pages.sort { |a, b| 
      if    a[1][:count] == 1 && b[1][:count] > 1
        1
      elsif b[1][:count] == 1 && a[1][:count] > 1
        -1
      else
        b[1][:lastused] - a[1][:lastused]
      end
    }.each_with_index { |c, i|
      break if i >= @min
      new_pages[c[0]] = c[1]
    }

    print "cache cut length [" + @pages.count.to_s + "] to [" + new_pages.count.to_s + "] " +
          "hit:[" + @hit.to_s + "] miss:[" + @miss.to_s + "] update:[" + @update.to_s + "]" + "\n"
    @pages = new_pages
  end

  ##########
  # for each pages
  ##########
  def date_res(url, conds, &b)
    cache = self[url]
    from, to = ViewThread.check_time(conds)
    if cache == nil || (
        cache[:created] < to && cache[:created] < TM.updatedat 
      )
      self[url] = b.call
      return b.call
    else
      return cache[:html]
    end
  end

  def must_be_refreshed(url, &b)
    cache = self[url]
    self[url] = b.call if cache == nil || cache[:created] < TM.updatedat
    self[url][:html]
  end
end
