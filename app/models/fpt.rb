#encoding:UTF-8
=begin
  * Description:指纹信息文件传输标准相关类
  * Author:YeChangLun
  * Date: 2011-10-29
=end


require 'rubygems'
require 'composite_primary_keys'

module ActiveRecord
  class Base
    def self.composite_where_clause id
      pks = ""
      primary_key.each_index  {|i|
        pk = primary_key[i]
        pks <<  "#{quoted_table_name()}.#{pk.to_s}='"<<id[i]<<"'"
        pks << " and " if i<(primary_key.size-1)
      }
      return pks
    end
  end
end
#十指模型
class NyzwIc < ActiveRecord::Base
  set_table_name "nyzw_ic"
  set_primary_key :ryno
end

class NyzwFp < ActiveRecord::Base
  set_table_name "nyzw_fp"
  set_primary_keys :ryno, :fpno

end

class NyzwTx < ActiveRecord::Base
  set_table_name "nyzw_tx"
  set_primary_keys :ryno, :fpno
end

class NyzwTzxx < ActiveRecord::Base
  set_table_name "nyzw_tzxx"
  set_primary_keys :ryno, :fpno
end

class NyzwZdyxx < ActiveRecord::Base
  set_table_name "nyzw_zdyxx"
  set_primary_keys :ryno, :fpno
end

#现场模型
class XczwIc < ActiveRecord::Base
  set_table_name "xczw_ic"
  set_primary_key :ajno
end

class XczwFp < ActiveRecord::Base
  set_table_name "xczw_fp"
  set_primary_keys :ajno, :fpno
end

class XczwTx < ActiveRecord::Base
  set_table_name "xczw_tx"
  set_primary_keys :ajno, :fpno
end

class XczwTzxx < ActiveRecord::Base
  set_table_name "xczw_tzxx"
  set_primary_keys :ajno, :fpno
end

class XczwZdyxx < ActiveRecord::Base
  set_table_name "xczw_zdyxx"
  set_primary_keys :ajno, :fpno
end


#十指模型-临时
class TempNyzwIc < ActiveRecord::Base
  set_table_name "t_nyzw_ic"
  set_primary_key :ryno
end

class TempNyzwFp < ActiveRecord::Base
  set_table_name "t_nyzw_fp"
  set_primary_keys :ryno, :fpno

end

class TempNyzwTx < ActiveRecord::Base
  set_table_name "t_nyzw_tx"
  set_primary_keys :ryno, :fpno
end

class TempNyzwTzxx < ActiveRecord::Base
  set_table_name "t_nyzw_tzxx"
  set_primary_keys :ryno, :fpno
end

class TempNyzwZdyxx < ActiveRecord::Base
  set_table_name "t_nyzw_zdyxx"
  set_primary_keys :ryno, :fpno
end

#现场模型
class TempXczwIc < ActiveRecord::Base
  set_table_name "t_xczw_ic"
  set_primary_key :ajno
end

class TempXczwFp < ActiveRecord::Base
  set_table_name "t_xczw_fp"
  set_primary_keys :ajno, :fpno
end

class TempXczwTx < ActiveRecord::Base
  set_table_name "t_xczw_tx"
  set_primary_keys :ajno, :fpno
end

class TempXczwTzxx < ActiveRecord::Base
  set_table_name "t_xczw_tzxx"
  set_primary_keys :ajno, :fpno
end

class TempXczwZdyxx < ActiveRecord::Base
  set_table_name "t_xczw_zdyxx"
  set_primary_keys :ajno, :fpno
end

#任务模型
class BkTask < ActiveRecord::Base
  set_table_name "bk_task"
  set_primary_key :task_id
end

class CcTask < ActiveRecord::Base
  set_table_name "cc_task"
  set_primary_key :task_id
end

class DcTask < ActiveRecord::Base
  set_table_name "dc_task"
  set_primary_key :task_id
end

class ZcTask < ActiveRecord::Base
  set_table_name "zc_task"
  set_primary_key :task_id
end

class XcTask < ActiveRecord::Base
  set_table_name "xc_task"
  set_primary_key :task_id
end

class Dict < ActiveRecord::Base
  set_table_name "sys_dict"
  def self.getDictByCode code
     find(:all,:conditions=>["code=?",code])
  end
end

class TbTask < ActiveRecord::Base
  set_table_name "tb_task"
  set_primary_key :tb_id
end

class TbTaskDest < ActiveRecord::Base
  set_table_name "tb_task_dest"
end

class DdStdm < ActiveRecord::Base
  set_table_name "dd_stdm"
end

class CfgSystem <ActiveRecord::Base
   set_table_name "cfg_system"
   set_primary_key :code
end

class Temp <ActiveRecord::Base
  set_table_name "tt"
  set_primary_keys :id,:x
end









