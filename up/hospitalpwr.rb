# coding: UTF-8
require 'bundler/setup'
require 'rubygems'
require 'sinatra'
require 'open-uri'
require 'haml'
require 'mysql'
require 'sequel'
require 'sass'
require './src/TchThread.rb'
require './src/ViewThread'
require './src/Dat'
require './src/Common'
require './src/DB'
require './src/DailyInfo'
require './src/article'
require './src/PageCache'
require './src/Maintainer'

set :haml, {:format => :html5 }
TM = TchThreadManager.new
PC = PageCache.new(50, 30)
Maintainer.new().start

# current
get '/current/' do
  redirect (Time.now.to_jst - MAX_TIMESPAN).from_link
end

# get day
reg_date = '/(\d{4})/(\d{2})/(\d{2})/'
get Regexp.new(reg_date + '$') do
  p = params[:captures]
  haml :day_index, :locals => { :day => Time.new(p[0], p[1], p[2]) }
end

reg_from   = '(?:from/(\d\d:\d\d:\d\d/)){0,1}'
reg_to     = '(?:to/(\d\d:\d\d:\d\d/)){0,1}'
reg_id     = '(?:id/(\S{9})/){0,1}'
reg_player = '(?:player/(\S+)/){0,1}'

get Regexp.new(reg_date + reg_from + reg_to + reg_id + reg_player + '$') do
  p = params[:captures]
  conds = {
    :date => Time.new(p[0], p[1], p[2]),
    :from => p[3], :to => p[4],
    :id   => p[5], :player => p[6]
  }

  PC.date_res(request.fullpath, conds) {
    vt = ViewThread.new(conds)
    haml :day_res, :locals => { :vt => vt, :info => { :crumb => vt.crumb } }
  }
end

reg_thread   = '/thread/(\d+)/'
reg_res      = '(?:res/(\d+?)/){0,1}'
reg_res_from = '(?:from/(\d+?)/){0,1}'
reg_res_to   = '(?:to/(\d+?)/){0,1}'
get Regexp.new(reg_thread + reg_res + reg_res_from + reg_res_to + '$') do
  p = params[:captures]
  vt = ViewOneThread.new( { :thread_no => p[0], :res => p[1], :res_from => p[2], :res_to => p[3] })
  haml :day_res, :locals => { :vt => vt, :info => { :crumb => vt.crumb } }
end


# get year/month
get %r{/(\d{4})/(\d{2})/$} do
  haml :month_index, :locals => {
    :month => Time.new(params[:captures][0], params[:captures][1])
  }
end

get %r{/(\d{4})/$} do
  haml :year_index, :locals => { :year => Time.new(params[:captures].first) }
end

# following methods are for each function
get '/' do
  PC.must_be_refreshed(request.fullpath) {
    haml :index, :locals => { :info => { :crumb => "" } }
  }
end

get '/style.xml' do
  sass :style
end

get '/db/:tablename' do
  haml :db, :locals => { :tablename => params[:tablename], :table => DB[params[:tablename].intern] }
end

get '/rss.xml' do
  haml :rss
end

get '/player/' do
  haml :player_index
end

# debug
get '/threads/' do
  haml :threads_index
end

get '/pagecache/' do
  haml :pagecache_index
end

get '/dailyinfo/' do
  haml :dailyinfo_index
end

=begin
get '/createdb' do
  DB.create_page_cache_table
end

get '/env' do
  ENV['VCAP_SERVICES']
end

get '/current_thread' do
  res = ""
  Dat.download.each { |t| res += t[:name] + "\n" }
  res
end
=end
