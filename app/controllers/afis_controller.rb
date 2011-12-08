#encoding:UTF-8
load "#{Rails.root}/app/models/send_receive.rb"
load "#{Rails.root}/app/models/fpt.rb"
class AfisController < ApplicationController
  def index
    SendReceive.init
    #SendReceive.make_waiting_info
   # SendReceive.scan_file
   b = BkTask.new
   b.task_id="BK12345"
   b.src="12345"
   b.ztbh="T12345"
   b.sqdwdm="111"
   b.sqdwmc="111"
   b.sqr="111"
   b.sqrq="20110911"
    b.lxr="123"
    b.lxdh="83883858"
   b.save!
  end

  #param[UserID]
  #param[Password]
  def getSearchTask
    puts "params=#{params[:UserID]}"
    puts "params=#{params[:UserID].encoding}"
    puts "params=#{params[:Password]}"
  end

  #param[UserID]
  #param[Password]
  def getXCTask

  end

end
