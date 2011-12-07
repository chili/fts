#encoding:UTF-8
load "#{Rails.root}/app/models/send_receive.rb"
class AfisController < ApplicationController
  def index
    SendReceive.init
    SendReceive.make_waiting_info
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
