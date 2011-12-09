#encoding:UTF-8
load "#{Rails.root}/app/models/send_receive.rb"
load "#{Rails.root}/app/models/fpt.rb"
class AfisController < ApplicationController
  def index
    SendReceive.init
    SendReceive.down_file
    #SendReceive.send_file
    #SendReceive.scan_file
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
