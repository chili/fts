require "fileutils"
require "net/ftp"
load "#{Rails.root}/app/models/fpt.rb"
def logger
    @logger ||= ::Rails.logger
    return @logger
end
#
#打包发送文件和接受其他省厅的文件
#
class SendReceive
  def self.init
    Rails.configuration.workspace  = "#{Rails.root}/files"  if(Rails.configuration.workspace.nil?)
    $dir = Rails.configuration.workspace
    puts "workspace is #{$dir}"
    Dir.mkdir("#{$dir}",777) if !Dir.exists?"#{$dir}"
    Dir.mkdir("#{$dir}/temp",777) if !Dir.exists?"#{$dir}/temp"
    Dir.mkdir("#{$dir}/send",777) if !Dir.exists?"#{$dir}/send"
    Dir.mkdir("#{$dir}/receive",777) if !Dir.exists?"#{$dir}/receive"
    if(Rails.configuration.gab) then
      DdStdm.find(:all).each do|s|
        Dir.mkdir("#{$dir}/send/#{s.code}",777) if !Dir.exists?"#{$dir}/send/#{s.code}"
        Dir.mkdir("#{$dir}/receive/#{s.code}",777) if !Dir.exists?"#{$dir}/receive/#{s.code}"
      end
    else
      Dir.mkdir("#{$dir}/send/01000",777)  if !Dir.exists?"#{$dir}/send/01000"
      Dir.mkdir("#{$dir}/receive/01000",777) if !Dir.exists?"#{$dir}/receive/01000"
    end
  end

  def self.down_file
    puts "connect ftp server"
     begin
      ftp = Net::FTP.new(Rails.configuration.ftp_host,Rails.configuration.ftp_username, Rails.configuration.ftp_password)
      ftp.chdir('/')
      server_files = ftp.ls("/").find_all{|i|i[0,10]=='drw-rw-rw-'}.map{|i|i.split(' ',9)[-1]} .each do|file|
        puts file
      end
    rescue Exception => ex
      puts ex
    ensure
      ftp.close
    end
  end

  def self.send_file
    tbTask = TbTask.find(:all,:conditions=>"fmq=1",:order=>"priority")
    tbTask.each do|t|
      puts t.src,t.tb_type
      objects = Array.new
      objects << t
      case t.tb_type
        when 0
          task = BkTask.find(t.src)
          if(!task.nil?) then
            objects << task
            objects.concat(SendReceive.make_nyzw_ic task.src)
          end
        when 1
          task = CcTask.find(t.src)
          if(!task.nil?) then
            objects << task
            objects.concat(SendReceive.make_nyzw_ic task.src)
          end
        when 2
          task = DcTask.find(t.src)
          if(!task.nil?) then
            objects << task
            objects.concat(SendReceive.make_nyzw_ic task.src)
          end
        when 3
          task = ZcTask.find(t.src)
          if(!task.nil?) then
            objects << task
            objects.concat(SendReceive.make_xczw_ic task.src,task.send_fp_no)
          end
        when 4
          task = XcTask.find(t.src)
          if(!task.nil?) then
            objects << task
            objects.concat(SendReceive.make_xczw_ic task.src)
          end
        #字典
        when 11
        objects << (Dict.getDictByCode t.src)
      end
      filename = "#{t.src}_#{Time.new.strftime("%Y%m%d%H%M%S%L")}.yml"
      File.open("#{$dir}/temp/#{filename}",'w:UTF-8') do|file|
        file.puts objects.to_yaml
      end
      if(Rails.configuration.gab) then
        dests = TbTaskDest.find(:all,:conditions=>["tb_id=?",t.tb_id])
        dests.each do|d|
          FileUtils.cp "#{$dir}/temp/#{filename}","#{$dir}/send/#{d.dest}/#{filename}"
        end
      else
        FileUtils.cp "#{$dir}/temp/#{filename}","#{$dir}/send/01000/#{filename}"
      end
      FileUtils.rm "#{$dir}/temp/#{filename}"
      #完成信息打包发送
      t.fmq = '2'
    end
  end

  def self.scan_file
   if(Rails.configuration.gab) then
     Dir.foreach("#{$dir}/receive") do|d|
        next if (d=="." || d== "..")
        Dir.foreach("#{$dir}/receive/#{d}") do|file|
          next if (file=="." || file== "..")
          	ActiveRecord::Base.transaction do
              begin
                load_file "#{$dir}/receive/#{d}/#{file}"
              rescue Exception => ex
                raise ActiveRecord::Rollback, ex.message
              end
						end
        end
     end
   end
  end

  def self.load_file file
    return if !File.file?file
    puts "loading #{file}"
    if file[/\.[^\.]+$/] == ".yml" then
      objects = YAML.load_file file
      tbTask = objects.shift
      case tbTask.tb_type
      when 0..4
        objects.each do|obj|
          clazz = obj.class
          begin
            exists = clazz.find(obj.id)
            exists.attributes = obj.attributes
            exists.save
          rescue ActiveRecord::RecordNotFound
            x = clazz.new
            x.initialize_dup(obj)
            x.id = obj.id
            x.save
          rescue Exception =>e
             logger.error e
          end
        end
      end
    end
  end

  #打包捺印信息
  def self.make_nyzw_ic(ryno)
    objects = Array.new
    nyzw_ic = NyzwIc.find(ryno)
    return if nyzw_ic.nil?
    objects << nyzw_ic
    fps = NyzwFp.find(:all,:conditions =>["ryno = ?",ryno])
    fps.each do |fp|
      objects << fp
      tzxx = NyzwTzxx.find(:all,:conditions =>["ryno = ? and fpno = ?",fp.ryno,fp.fpno],:order => "fpno")
      objects.concat (tzxx) if !tzxx.nil?
      zdyxx = NyzwZdyxx.find(:all,:conditions =>["ryno = ? and fpno = ?",fp.ryno,fp.fpno],:order => "fpno")
      objects.concat (zdyxx) if !zdyxx.nil?
      tx = NyzwTx.find(:all,:conditions =>["ryno = ? and fpno = ?",fp.ryno,fp.fpno],:order => "fpno")
      objects.concat (tx) if !tx.nil?
    end
    return objects
  end
  #打包捺印信息
  #参数:案件编号,发送指纹编号字符串(默认为空表示全部发送)
  def self.make_xczw_ic(ajno,fpnos="")
    objects = Array.new
    xczw_ic = XczwIc.find(ajno)
    return if xczw_ic.nil?
    objects << xczw_ic
    fps = XczwFp.find(:all,:conditions =>["ajno = ?",ajno] )
    fps.each do |fp|
      next if (!fpnos.nil? && !fpnos.empty? && !fpnos.include?(fp.fpno))
      objects << fp
      tzxx = XczwTzxx.find(:all,:conditions =>["ajno = ? and fpno = ?",fp.ajno,fp.fpno],:order => "fpno")
      objects.concat (tzxx) if !tzxx.nil?
      zdyxx = XczwZdyxx.find(:all,:conditions =>["ajno = ? and fpno = ?",fp.ajno,fp.fpno],:order => "fpno")
      objects.concat (zdyxx) if !zdyxx.nil?
      tx = XczwTx.find(:all,:conditions =>["ajno = ? and fpno = ?",fp.ajno,fp.fpno],:order => "fpno")
      objects.concat (tx) if !tx.nil?
    end
    return objects
  end
end