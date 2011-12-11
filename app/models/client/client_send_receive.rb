class ClientSendReceive<SendReceive

  def self.down_file
    FileUtils.mv Dir.glob("#{$rw_dir}/#{$config.hostcode}/receive/010000/*.*"),"#{$w_dir}/receive/010000",:force => true
    puts "#{$rw_dir}/#{$config.hostcode}/receive/010000/*.*,#{$w_dir}/receive/010000"
  end

  def self.upload_file
    FileUtils.mv Dir.glob("#{$w_dir}/send/010000/*.*"),"#{$rw_dir}/#{$config.hostcode}/send/010000/",:force => true
  end
end