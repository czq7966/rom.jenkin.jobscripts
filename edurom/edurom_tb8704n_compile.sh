# 参数默认值 代码相关
# _project=${_project:-rom/nd3}　　	 	# 默认库名
# _branchver=${_branchver:-test}　		# 版本分支，现有:dev rel int test tibet_dev tibet_rel english_dev english_rel
# _branchcr=${_branchcr:-dev ${_branchcode}}	# 合并分支，后面的分支rebase到前面的分支
# _branchmerge=${_branchmerge:-}		# 临时从哪个分支上过来，是merge操作
# _branchpick=${_branchpick:-}			# 临时从哪个CR上pick过来
# _variant=${_variant:-userdebug}		# user/userdebug
_product=lineage_tb8704n
# _nettype=${_nettype:-wifi}			# 网络支持：wifi 4g
# _device=${_device:-ND3}				# 设备：ND3
_device=EDUROM_tb8704n
# _sku=${_sku:-CN_${_branchcode}}		# 区域码：CN

# 参数默认值 编译相关
# _pickcr=${_pickcr:-yes}			# 是否从_branchcr获取未入库的CR
_makeota=no
# _makeclean=${_makeclean:-yes}			# 编译android是，是否清空中间件
_makeclean=no
# _prebuildapp=${_prebuildapp:-yes}		# 是否预编译集成App，编译rk3288分支时，该参数请设为 no
_prebuildapp=yes
# _verifiedfb=${_verifiedfb:-yes}		# 编译验证反馈给Gerrit
# _tempfile=${_tempfile:-temp.txt}		# 临时文件，主要用于临时存储Gerrit上的相关CR
_svn_server_pdir="none"
_svn_server_pdir_qa="none"
_ftp_server_pdir_qa="none"


source ${JENKINS_HOME}/jobscripts/edurom/base/edurom_make.sh

