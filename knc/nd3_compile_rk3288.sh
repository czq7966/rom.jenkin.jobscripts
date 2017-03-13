# 参数默认值 代码相关
# _project=${_project:-rom/nd3}　　	 	# 默认库名
_branchver=rk3288
_branchcode=rk3288
_branchcr=rk3288
_branchmerge=origin/rk3288_merge
 _branchpick=(50d29102bc2a1994b14a020255f4bea5df1edf60)
# _variant=${_variant:-userdebug}		# user/userdebug
_product=rk3288
# _nettype=${_nettype:-wifi}			# 网络支持：wifi 4g
# _device=${_device:-ND3}			# 设备：ND3
# _sku=${_sku:-CN_${_branchcode}}		# 区域码：CN

# 参数默认值 编译相关
# _pickcr=${_pickcr:-yes}			# 是否从_branchcr获取未入库的CR
_makeota=no
_makeclean=no
_lunchsku=${_lunchsku:-no}
_prebuildapp=${_prebuildapp:-no}
# _verifiedfb=${_verifiedfb:-yes}		# 编译验证反馈给Gerrit
# _tempfile=${_tempfile:-temp.txt}		# 临时文件，主要用于临时存储Gerrit上的相关CR
_svn_server_pdir="none"
_svn_server_pdir_qa="none"
_ftp_server_pdir_qa="none"


source ${JENKINS_HOME}/jobscripts/nd3/base/nd3_make.sh

