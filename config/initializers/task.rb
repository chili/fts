require 'rubygems'
require 'rufus/scheduler'
load "#{Rails.root}/app/models/send_receive.rb"
load "#{Rails.root}/app/models/gab/gab_send_receive.rb" if Rails.configuration.gab
load "#{Rails.root}/app/models/client/client_send_receive.rb" unless Rails.configuration.gab
load "#{Rails.root}/app/models/fpt.rb"
load "#{Rails.root}/app/models/fpt_parser.rb"

scheduler = Rufus::Scheduler.start_new

SendReceive.init
SendReceive.remote_init
puts "config hostcode = #{Rails.configuration.hostcode}"
puts "config isGab = #{Rails.configuration.gab}"
if  Rails.configuration.gab then
 scheduler.every("30s") do
  load "#{Rails.root}/app/models/send_receive.rb"
  load "#{Rails.root}/app/models/gab/gab_send_receive.rb" if Rails.configuration.gab
  load "#{Rails.root}/app/models/client/client_send_receive.rb" unless Rails.configuration.gab
  load "#{Rails.root}/app/models/fpt.rb"
  load "#{Rails.root}/app/models/fpt_parser.rb"
    puts Time.new
    GabSendReceive.down_file
    GabSendReceive.scan_file
    SendReceive.send_file
    GabSendReceive.upload_file
  end
else
scheduler.every("30s") do
  load "#{Rails.root}/app/models/send_receive.rb"
  load "#{Rails.root}/app/models/gab/gab_send_receive.rb" if Rails.configuration.gab
  load "#{Rails.root}/app/models/client/client_send_receive.rb" unless Rails.configuration.gab
  load "#{Rails.root}/app/models/fpt.rb"
  load "#{Rails.root}/app/models/fpt_parser.rb"
    puts Time.new
    ClientSendReceive.down_file
    ClientSendReceive.scan_file
    SendReceive.send_file
    ClientSendReceive.upload_file
end
end
