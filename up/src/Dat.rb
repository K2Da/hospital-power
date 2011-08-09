# coding: UTF-8
require 'open-uri'
require './src/config'

class Dat
  SUBJECT = "http://yuzuru.2ch.net/gamefight/subject.txt"
  THREAD  = "http://yuzuru.2ch.net/gamefight/dat/"

  REG_SUBLINE = /(\d+?)\.dat<>(.*) \((\d+)\)$/u

  def Dat.current_threads
    subject =
      open(SUBJECT, "r:Shift_JIS", 
           {'Cache-Control' => 'no-cache', 'Pragma' => 'no-cache'}
          ).read.encode("UTF-8", "Shift_JIS", :invalid => :replace, :undef => :replace)
    Dat.get_threads(subject)
  end

  def Dat.get_threads(subject)
    ret = []
    subject.split("\n").find_all { |l| REG_TITLE.match(l) }.each { |s| ret << Dat.thread_info(s) }
    ret
  end

  def Dat.get_thread(no)
    open(THREAD + no.to_s + ".dat", "r:Shift_JIS",
      {'Cache-Control' => 'no-cache', 'Pragma' => 'no-cache'}).read 
  end

  def Dat.thread_info(line)
    c = REG_SUBLINE.match(line).captures
    { :no => c[0], :name => c[1], :count => c[2].to_i }
  end
end
