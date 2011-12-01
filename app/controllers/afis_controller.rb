#encoding:UTF-8
class AfisController < ApplicationController
  def index
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
