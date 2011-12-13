class ClientSendReceive<SendReceive

  def self.down_file
    puts "down #{$rw_dir}/#{$config.hostcode}/receive/010000/*.* to #{$w_dir}/receive/010000"
    FileUtils.mv Dir.glob("#{$rw_dir}/#{$config.hostcode}/receive/010000/*.*"),"#{$w_dir}/receive/010000",:force => true
  end

  def self.upload_file
    puts "upload #{$w_dir}/send/010000/*.* to #{$rw_dir}/#{$config.hostcode}/send/010000/"
    FileUtils.mv Dir.glob("#{$w_dir}/send/010000/*.*"),"#{$rw_dir}/#{$config.hostcode}/send/010000/",:force => true
  end
end