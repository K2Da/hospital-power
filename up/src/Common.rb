class Time 
  def to_date
    Time.new(year, month, day)
  end

  def to_month
    Time.new(year, month)
  end

  def to_year
    Time.new(year)
  end

  def comparetime
    strftime("%Y%m%d%H%M")
  end

  def to_link
    strftime('/%Y/%m/%d/from/%H:%M:%S/')
  end
  
  def to_display_time
    strftime('%H:%M:%S')
  end

  def to_year_link
    strftime('/%Y/')
  end

  def to_month_link
    strftime('/%Y/%m/')
  end

  def to_day_link
    strftime('/%Y/%m/%d/')
  end

  def to_jst
    getutc + 9 * 60 * 60
  end

  def to_year_crumb
    '<a href="' + to_year_link + '">' + strftime("%Y")+ '</a>'
  end

  def to_month_crumb
    '<a href="' + to_month_link + '">' + strftime("%B") + '</a>, ' + to_year_crumb
  end

  def to_day_crumb
    '<a href="' + to_month_link + '">' + strftime("%B") + '</a> ' + '<a href="' + to_day_link + '">' + strftime("%d") + '</a>, ' + to_year_crumb
  end
end
