#encoding:UTF-8
=begin
  * Description:指纹信息文件传输标准相关类
  * Author:YeChangLun
  * Date: 2011-10-29
=end



#十指模型
class NyzwIc < ActiveRecord::Base
  set_table_name "nyzw_ic"
  set_primary_key :ryno
end

class NyzwFp < ActiveRecord::Base
  set_table_name "nyzw_fp"
end

class NyzwTx < ActiveRecord::Base
  set_table_name "nyzw_tx"
end

class NyzwTzxx < ActiveRecord::Base
  set_table_name "nyzw_tzxx"
end

class NyzwZdyxx < ActiveRecord::Base
  set_table_name "nyzw_zdyxx"
end

#现场模型
class XczwIc < ActiveRecord::Base
  set_table_name "xczw_ic"
end

class XczwFp < ActiveRecord::Base
  set_table_name "xczw_fp"
end

class XczwTx < ActiveRecord::Base
  set_table_name "xczw_tx"
end

class XczwTzxx < ActiveRecord::Base
  set_table_name "xczw_tzxx"
end

class XczwZdyxx < ActiveRecord::Base
  set_table_name "xczw_zdyxx"
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






