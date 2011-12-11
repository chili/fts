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
    $config = Rails.configuration
    $w_dir = $config.workspace + "/#{$config.hostcode}" unless defined? $w_dir
    puts "workspace is #{$w_dir}"
    FileUtils.mkdir_p "#{$w_dir}/temp"  unless  Dir.exists?"#{$w_dir}/temp"
    FileUtils.mkdir_p "#{$w_dir}/send"  unless  Dir.exists?"#{$w_dir}/send"
    FileUtils.mkdir_p "#{$w_dir}/receive"  unless  Dir.exists?"#{$w_dir}/receive"
    if($config.gab) then
      DdStdm.find(:all).each do|s|
        Dir.mkdir("#{$w_dir}/send/#{s.code}",0)  unless Dir.exists?"#{$w_dir}/send/#{s.code}"
        Dir.mkdir("#{$w_dir}/receive/#{s.code}",0) unless Dir.exists?"#{$w_dir}/receive/#{s.code}"
      end
    else
      Dir.mkdir("#{$w_dir}/send/010000",0)  unless Dir.exists?"#{$w_dir}/send/010000"
      Dir.mkdir("#{$w_dir}/receive/010000",0) unless Dir.exists?"#{$w_dir}/receive/010000"
    end
  end

  def self.remote_init
    $rw_dir =  $config.remote_workspace
    puts "remote workspace is #{$rw_dir}"
    FileUtils.mkdir_p "#{$rw_dir}"  unless  Dir.exists?"#{$rw_dir}"
    DdStdm.find(:all).each do|s|
      FileUtils.mkdir_p("#{$rw_dir}/#{s.code}/send/010000")  unless Dir.exists?"#{$rw_dir}/#{s.code}/send/010000"
      FileUtils.mkdir_p("#{$rw_dir}/#{s.code}/receive/010000") unless Dir.exists?"#{$rw_dir}/#{s.code}/receive/010000"
      FileUtils.mkdir_p "#{$rw_dir}/010000/send/#{s.code}"  unless  Dir.exists?"#{$rw_dir}/010000/send/#{s.code}"
      FileUtils.mkdir_p "#{$rw_dir}/010000/receive/#{s.code}"  unless  Dir.exists?"#{$rw_dir}/010000/receive/#{s.code}"
    end
  end

  def self.down_file
  end

  def self.upload_file

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
      File.open("#{$w_dir}/temp/#{filename}",'w:UTF-8') do|file|
        file.puts objects.to_yaml
      end
      if($config.gab) then
        dests = TbTaskDest.find(:all,:conditions=>["tb_id=?",t.tb_id])
        dests.each do|d|
          FileUtils.cp "#{$w_dir}/temp/#{filename}","#{$w_dir}/send/#{d.dest}/#{filename}"
        end
      else
        FileUtils.cp "#{$w_dir}/temp/#{filename}","#{$w_dir}/send/010000/#{filename}"
      end
      FileUtils.rm "#{$w_dir}/temp/#{filename}"
      #完成信息打包发送
      t.fmq = '2'
      t.save
    end
  end

  def self.scan_file
     Dir.foreach("#{$w_dir}/receive") do|d|
        next if (d=="." || d== "..")
        Dir.foreach("#{$w_dir}/receive/#{d}") do|file|
          next if (file=="." || file== "..")
          	ActiveRecord::Base.transaction do
              begin
                load_file "#{$w_dir}/receive/#{d}/#{file}"
              rescue Exception => ex
                raise ActiveRecord::Rollback, ex.message
              end
						end
        end
     end
  end

  # @param file [Object]
  def self.load_file file
    return if !File.file?file
    puts "loading #{file}"
    if file[/\.[^\.]+$/] == ".yml" then
      objects = YAML.load_file file
      tbTask = objects.shift
      puts tbTask.tb_type
      case tbTask.tb_type
        when 0..4
          puts "load task 0..4"
          loadTask objects
      end
    end
  end

  def self.loadTask objects
      objects.each do|obj|
        clazz = obj.class
        begin
          puts obj.id
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



