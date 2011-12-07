load "#{Rails.root}/app/models/fpt.rb"
class SendReceive
  def self.init
    Rails.configuration.workspace  = "#{Rails.root}/files"  if(Rails.configuration.workspace.nil?)
    dir = Rails.configuration.workspace
    puts "workspace is #{dir}"
    Dir.mkdir("#{dir}",777) if !Dir.exists?"#{dir}"
    Dir.mkdir("#{dir}/temp",777) if !Dir.exists?"#{dir}/temp"
    Dir.mkdir("#{dir}/send",777) if !Dir.exists?"#{dir}/send"
    Dir.mkdir("#{dir}/receive",777) if !Dir.exists?"#{dir}/receive"
    DdStdm.find(:all).each do|s|
      puts "#{dir}/send/#{s.code}"
      Dir.mkdir("#{dir}/send/#{s.code}",777) if !Dir.exists?"#{dir}/send/#{s.code}"
      Dir.mkdir("#{dir}/receive/#{s.code}",777) if !Dir.exists?"#{dir}/receive/#{s.code}"
    end
  end
  def self.make_waiting_info
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
            objects.push(SendReceive.make_nyzw_ic task.src)
          end
        when 1
          task = CcTask.find(t.src)
          if(!task.nil?) then
            objects << task
            objects.push(SendReceive.make_nyzw_ic task.src)
          end
        when 2
          task = DcTask.find(t.src)
          if(!task.nil?) then
            objects << task
            objects.push(SendReceive.make_nyzw_ic task.src)
          end
        when 3
          task = ZcTask.find(t.src)
          if(!task.nil?) then
            objects << task
            objects.push(SendReceive.make_xczw_ic task.src,task.send_fp_no)
          end
        when 4
          task = XcTask.find(t.src)
          if(!task.nil?) then
            objects << task
            objects.push(SendReceive.make_xczw_ic task.src)
          end
        #字典
        when 11
        objects << (Dict.getDictByCode t.src)
      end
      File.open("#{Rails.configuration.workspace}/temp#{t.src}_#{Time.new.strftime("%Y%m%d%H%M%S%L")}.yml",'w:UTF-8') do|file|
        file.puts objects.to_yaml
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
      objects << tzxx if !tzxx.nil?
      zdyxx = NyzwZdyxx.find(:all,:conditions =>["ryno = ? and fpno = ?",fp.ryno,fp.fpno],:order => "fpno")
      objects << zdyxx if !zdyxx.nil?
      tx = NyzwTx.find(:all,:conditions =>["ryno = ? and fpno = ?",fp.ryno,fp.fpno],:order => "fpno")
      objects << tx if !tx.nil?
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
      next if (!fpnos.empty? && !fpnos.include?(fp.fpno))
      objects << fp
      tzxx = XczwTzxx.find(:all,:conditions =>["ajno = ? and fpno = ?",fp.ajno,fp.fpno],:order => "fpno")
      objects << tzxx if !tzxx.nil?
      zdyxx = XczwZdyxx.find(:all,:conditions =>["ajno = ? and fpno = ?",fp.ajno,fp.fpno],:order => "fpno")
      objects << zdyxx if !zdyxx.nil?
      tx = XczwTx.find(:all,:conditions =>["ajno = ? and fpno = ?",fp.ajno,fp.fpno],:order => "fpno")
      objects << tx if !tx.nil?
    end
    return objects
  end
end