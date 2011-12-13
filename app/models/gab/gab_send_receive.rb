class GabSendReceive < SendReceive
  def self.load_file file
      puts "gab load #{file}"
  end

  def self.down_file
      Dir.foreach($rw_dir) do|dir|
        next if (dir=="." || dir== ".." || dir == $config.hostcode)
        puts "gab down #{$rw_dir}/#{dir}/send/#{$config.hostcode}/*.* to #{$w_dir}/receive/#{dir}/"
        FileUtils.mv Dir.glob("#{$rw_dir}/#{dir}/send/#{$config.hostcode}/*.*"),"#{$w_dir}/receive/#{dir}/",:force => true
      end
  end

  def self.upload_file
      Dir.foreach("#{$w_dir}/send") do|dir|
        next if (dir=="." || dir== "..")
        puts "gab upload #{$w_dir}/send/#{dir}/*.* to #{$rw_dir}/#{dir}/receive/#{$config.hostcode}/"
        FileUtils.mv Dir.glob("#{$w_dir}/send/#{dir}/*.*"),"#{$rw_dir}/#{dir}/receive/#{$config.hostcode}/",:force => true
      end
  end
end