#encoding:UTF-8
require "#{Rails.root}/app/models/fpt.rb"
class AfisController < ApplicationController
  def index
    puts "start serialize"
    puts "#{Rails.root}/app/models/fpt.rb"
    id = "R5002335209992008120003"
    datas_object = NyzwIc.find(id)
    File.open("#{id}.yml",'w:UTF-8') do|file|
      file.puts datas_object.to_yaml
    end
    datas_object = NyzwTx.find(:all, :conditions => ["ryno=? and fpno=?", id, "01"])
     File.open("#{id}_01.yml",'w:UTF-8') do|file|
      file.puts datas_object.to_yaml
     end

    datas_object = YAML.load File.read("#{id}.yml")
    datas_object.save
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
