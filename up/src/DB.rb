require 'rubygems'
require 'sequel'
require 'json'

def get_mysql_connection_info
  JSON.load(ENV['VCAP_SERVICES'])["mysql-5.1"][0]["credentials"].values_at(
    "hostname", "port", "name", "user", "password"
  )
end

host, port, db, user, pwd =  get_mysql_connection_info
DB = Sequel.connect(
    "mysql://" + host + ":" + port.to_s + "/" +db, 
    { :user => user, :password => pwd }
  )

THR = DB[:thread]

##########
# THR
##########
def DB.create_thread_table
  DB.create_table? :thread do
    primary_key :no
    Integer  :no
    String   :title, :size => 64
    DateTime :from
    DateTime :to
    Integer  :res_count
    File     :dat, :size => :medium
  end
end

def THR.params(t, dat)
  { :no => t.no, :title => t.title, :from => t.from, :to => t.to, :res_count => t.res.count, :dat => dat }
end

def THR.insert(t, dat)
  DB[:thread].insert(THR.params(t, dat))
end

def THR.update(t, dat)
  DB[:thread].update(THR.params(t, dat))
end

def THR.delete(t)
  DB[:thread].filter('no = ?', t.no).delete
end

def THR.newer(d)
  DB[:thread].filter('`to` > ?', d)
end

def THR.dat(no)
  DB[:thread].filter('no = ?', no)[:no => no]
end

def THR.info
  DB[:thread].select(:no, :title, :from, :to, :res_count)
end

##########
# DIC
##########
def DB.create_page_cache_table
  DB.create_table? :daily_info_cache do
    primary_key :cache_date
    String   :cache_date, :size => 8
    File     :cache, :size => :medium
  end
end
DB.create_page_cache_table

DIC = DB[:daily_info_cache]
DB[:daily_info_cache].delete

def DIC.delete(date)
  DB[:daily_info_cache].filter('cache_date = ?', date.to_day).delete
end 

def DIC.get(date)
  r = DB[:daily_info_cache].filter('cache_date = ?', date.to_day)[:cache_date => date.to_day]
  return nil if r == nil
  YAML.load(r[:cache])
end 

def DIC.insert(date, di)
  DB[:daily_info_cache].insert( {
    :cache_date => date.to_day,
    :cache => "# encoding: UTF-8\n" + YAML.dump(di)
  } )
end
