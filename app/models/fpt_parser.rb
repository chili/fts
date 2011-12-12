#encoding:UTF-8
require File.dirname(__FILE__) + '/fpt.rb'
class FPTParserV4
  #解析FPT文件
  # @param file_name [Object]
  def parse file_name
   puts "load #{file_name}"
   return if  File.size?(file_name).nil?
   size =  File.size(file_name)
   File.open(file_name,"rb") do |fin|
    puts "start parse"
    header = parse_header fin
    raise "FPT版本不正确" unless FPTFile.VERSION.eql?header.version
    raise "文件大小异常" unless size == header.c101
    p_size = to_i fin.read(8)
    p_type = trim fin.read(2)
    case p_type
      when "02"
        parse_nyzw fin
      when "03"
        parse_xczw fin
    end
   end
  end

  def parse_header io
    header = FPTV4Header.new
    begin
     header.version = trim io.read(7)
     header.c101 = to_i io.read(12)
     header.c102 = to_i io.read(2)
     header.c103 = to_i io.read(6)
     header.c104 = to_i io.read(6)
     header.c105 = to_i io.read(6)
     header.c106 = to_i io.read(6)
     header.c107 = to_i io.read(6)
     header.c108 = to_i io.read(6)
     header.c109 = to_i io.read(6)
     header.c110 = to_i io.read(6)
     header.c111 = to_i io.read(6)
     header.c112 = to_i io.read(6)
     header.c113 = to_i io.read(6)
     header.c114 = trim io.read(6)
     header.c115 = trim io.read(14)
     header.c116 = trim io.read(12)
     header.c117 = trim io.read(12)
     header.c118 = trim io.read(70)
     header.c119 = trim io.read(30)
     header.c120 = trim io.read(4)
     header.c121 = trim io.read(10)
     header.c122 = trim io.read(512)
     skip = io.read(1)
    rescue
      raise "文件格式不正确"
    end
    return header
  end

  def parse_nyzw io
    begin
      no = io.read(6)
      xtlx     = trim io.read(4)
      ryno     = trim io.read(23)
      ny,tzxx,zdyxx,tx = nil,nil,nil,nil
      begin
        ny = TempNyzwIc.find(ryno)
      rescue ActiveRecord::RecordNotFound
         ny = TempNyzwIc.new
      end
      ny.xtlx = xtlx
      ny.ryno  = ryno
      ny.kahao = trim io.read(23)
      ny.xm    = trim io.read(30)
      ny.bm    = trim io.read(30)
      ny.xb    = trim io.read(1)
      ny.csrq  = trim io.read(8)
      ny.gj    = trim io.read(3)
      ny.mz    = trim io.read(2)
      ny.sfzh  = trim io.read(18)
      ny.zjlx  = trim io.read(3)
      ny.zjhm  = trim io.read(20)
      ny.hjddm = trim io.read(6)
      ny.hjd   = trim io.read(70)
      ny.xzzdm = trim io.read(6)
      ny.xzz   = trim io.read(70)
      ny.lb    = trim io.read(2)
      ny.ajlb1 = trim io.read(6)
      ny.ajlb2 = trim io.read(6)
      ny.ajlb3 = trim io.read(6)
      ny.qkbs  = trim io.read(1)
      ny.qkqk  = trim io.read(1024)
      ny.nydwdm= trim io.read(12)
      ny.nydwmc= trim io.read(70)
      ny.nyr   = trim io.read(30)
      ny.nyrq  = trim io.read(8)
      ny.xcjb  = trim io.read(1)
      ny.jj    = trim io.read(6)
      ny.xcmd  = trim io.read(5)
      ny.xgrybh= trim io.read(23)
      ny.xgajbh= trim io.read(23)
      ny.xcyxsx= trim io.read(1)
      ny.xcqqsm= trim io.read(512)
      ny.xcdwdm= trim io.read(12)
      ny.xcdwmc= trim io.read(70)
      ny.xcsqrq= trim io.read(8)
      ny.lxr   = trim io.read(30)
      ny.lxdh  =   trim io.read(40)
      ny.spr   = trim io.read(30)
      ny.beizhu= trim io.read(512)
      ny.xczt  = trim io.read(1)
      ny.save
      image_size = to_i io.read(6)
      io.read(image_size) if image_size > 0
      send_fp_num = to_i io.read(2)
      begin
        fp_size = to_i io.read(7)
        fp_send_no = trim io.read(2)
        fpno = "%02d" %(trim io.read(2))
        begin
          fp = TempNyzwFp.find([ryno,fpno])
        rescue ActiveRecord::RecordNotFound
          fp = TempNyzwFp.new
          fp.id = [ryno,fpno]
          fp.save
        end
        begin
          tzxx = TempNyzwTzxx.find([ryno, fpno])
        rescue ActiveRecord::RecordNotFound
          tzxx = TempNyzwTzxx.new
          tzxx.id = [ryno, fpno]
        end
        tzxx.tztqff = trim io.read(1)
        tzxx.zwwx1 = trim io.read(1)
        tzxx.zwwx2 = trim io.read(1)
        tzxx.zwfx = trim io.read(5)
        tzxx.zxd = trim io.read(14)
        tzxx.fzx = trim io.read(14)
        tzxx.zsj = trim io.read(14)
        tzxx.ysj = trim io.read(14)
        tzxx.save
        fp.tzdgs = to_i io.read(3)
        tzxx.tzd = trim io.read(1800)
        zdyxxcd = to_i io.read(6)
        #自定义信息
        if zdyxxcd >0 then
          begin
            zdyxx = TempNyzwZdyxx.find([ryno, fpno])
          rescue ActiveRecord::RecordNotFound
            zdyxx = TempNyzwZdyxx.new
            zdyxx.id = [ryno, fpno]
          end
          zdyxx.zdyxx = io.read(zdyxxcd)
          zdyxx.save
        end
        fp.tx_x = trim io.read(3)
        fp.tx_y = trim io.read(3)
        fp.fbl = trim io.read(3)
        fp.ysdm = trim io.read(4)
        txcd = to_i io.read(6)
        fp.txcd = txcd
        if(txcd >0) then
          begin
            tx = TempNyzwTx.find([ryno, fpno])
          rescue ActiveRecord::RecordNotFound
            tx = TempNyzwTx.new
            tx.id = [ryno, fpno]
          end
          puts "******************#{tx.id}"
          io.read(txcd)
          tx.save
        end
        fp.save
        gsfs = io.read(1)
      end while $FPT_FS.eql?gsfs
    rescue
      puts $!
      raise "捺印指纹格式不正确"
    end
    return ny
  end

  def parse_xczw io

  end
end

class FPTFile
  #文件分隔符
  $FPT_FS = 0x1C
  #组分隔符
  $FPT_ = 0x1D
  #空白字符
  $FPT_NUL = 0x0
  @@VERSION = "FPT0400"
  def self.VERSION
     @@VERSION
  end

end

class FPTV4Header
  attr_accessor :version,:c101,:c102,:c102,:c103, :c104, :c105, :c106, :c107, :c108, :c109, :c110, :c111, :c112, :c113, :c114, :c115, :c116, :c117, :c118, :c119, :c120, :c121, :c122
end

def trim line
  #puts "s:#{line},#{line.size}"
  line.strip! unless line.nil?
  #puts "e:#{line},#{line.size}"
  return line
end

def to_i line
  s_num = trim line
  unless (s_num.nil?) then
    return s_num.to_i
  else
    return 0
  end
end