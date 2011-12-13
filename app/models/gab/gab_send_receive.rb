#encoding:UTF-8

class GabSendReceive < SendReceive
  # @param file [Object]
  def self.load_file file
    return if !File.file?file
    puts "loading #{file}"
    if file[/\.[^\.]+$/] == ".yml" then
      objects = YAML.load_file file
      tbTask = objects.shift
      case tbTask.tb_type
        when 0..3
          load_direct_task objects
      end
    end
  end

  #解析任务信息
  def self.load_bk_task objects
    task = objects.shift
    begin
        exists = BkTask.find(obj.id)
        SendReceive.add_task_log task.id,"任务已经上报，不能重复上报"
      rescue ActiveRecord::RecordNotFound
        x = clazz.new
        x.initialize_dup(obj)
        x.id = obj.id
        x.save
        save_info objects
      rescue Exception =>e
        logger.error e
      end
  end

  # 保存信息
  def self.save_info objects
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

  def self.loadTask objects
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

  def self.down_file
      Dir.foreach($rw_dir) do|dir|
        next if (dir=="." || dir== ".." || dir == $config.hostcode)
        #puts "gab down #{$rw_dir}/#{dir}/send/#{$config.hostcode}/*.* to #{$w_dir}/receive/#{dir}/"
        FileUtils.mv Dir.glob("#{$rw_dir}/#{dir}/send/#{$config.hostcode}/*.*"),"#{$w_dir}/receive/#{dir}/",:force => true
      end
  end

  def self.upload_file
      Dir.foreach("#{$w_dir}/send") do|dir|
        next if (dir=="." || dir== "..")
        #puts "gab upload #{$w_dir}/send/#{dir}/*.* to #{$rw_dir}/#{dir}/receive/#{$config.hostcode}/"
        FileUtils.mv Dir.glob("#{$w_dir}/send/#{dir}/*.*"),"#{$rw_dir}/#{dir}/receive/#{$config.hostcode}/",:force => true
      end
  end
end