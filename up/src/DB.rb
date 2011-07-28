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

# create table
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

def params(t, dat)
  { :no => t.no, :title => t.title, :from => t.from, :to => t.to, :res_count => t.res.count, :dat => dat }
end

def THR.insert(t, dat)
  DB[:thread].insert(params(t, dat))
end

def THR.update(t, dat)
  DB[:thread].update(params(t, dat))
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
