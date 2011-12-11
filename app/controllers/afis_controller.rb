#encoding:UTF-8
require "savon"
require "base64"
load "#{Rails.root}/app/models/send_receive.rb"
load "#{Rails.root}/app/models/gab/gab_send_receive.rb" if Rails.configuration.gab
load "#{Rails.root}/app/models/client/client_send_receive.rb" unless Rails.configuration.gab
load "#{Rails.root}/app/models/fpt.rb"
class AfisController < ApplicationController
  def index
    #gabsendreceive.init
    #gabsendreceive.remote_init
    #gabsendreceive.down_file
    #gabsendreceive.upload_file
    ClientSendReceive.init
    ClientSendReceive.remote_init
    ClientSendReceive.down_file
    ClientSendReceive.upload_file
    ClientSendReceive.scan_file
    #SendReceive.down_file
    SendReceive.send_file
    #SendReceive.scan_file
  end

  #param[UserID]
  #param[Password]
  def getSearchTask
    puts "*************"
    client = Savon::Client.new do
      wsdl.document = "http://59.108.119.66:8080/gabxcws/services/gafisxcws?wsdl"
    end
    request_params = {
        :userId => "szxc",
        :pwd  => "szxc",
        :ryno      => "R3100000009991982053988",
        :xm => "",
        :xb => "",
        :idno => "",
        :zjlb => "",
        :zjhm => "",
        :hjddm => "",
        :xzzdm => "",
        :rylb => "",
        :ajlb => "",
        :qkbs => "",
        :xcjb => "",
        :nydwdm => "",
        :startDate => "",
        :endDate => ""
      }
    begin
    response = client.request :getTenprintByCondition do
      soap.body = request_params
    end
    body =  response.body
    content_enc =  body[:get_tenprint_by_condition_response][:get_tenprint_by_condition_return]
    content =  Base64.decode64(content_enc)
    puts content
    rescue Savon::Error => error
      logger.error error.to_s
    end
  end

  #param[UserID]
  #param[Password]
  def getXCTask

  end

end
