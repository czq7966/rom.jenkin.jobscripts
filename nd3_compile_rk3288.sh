# 参数默认值 代码相关
# _project=${_project:-rom/nd3}　　	 	# 默认库名
_branchver=rk3288　		# 版本分支，现有:dev rel int test tibet_dev tibet_rel english_dev english_rel
_branchcode=rk3288		# 代码分支
_branchcr=rk3288	# 合并分支，后面的分支rebase到前面的分支
_branchmerge=origin/rk3288_merge		# 临时从哪个分支上过来，是merge操作
 _branchpick=(50d29102bc2a1994b14a020255f4bea5df1edf60)			# 临时从哪个CR上pick过来
# _variant=${_variant:-userdebug}		# user/userdebug
_product=rk3288			# 产品：nd3 nd2x
# _nettype=${_nettype:-wifi}			# 网络支持：wifi 4g
# _device=${_device:-ND3}			# 设备：ND3
# _sku=${_sku:-CN_${_branchcode}}		# 区域码：CN

# 参数默认值 编译相关
# _pickcr=${_pickcr:-yes}			# 是否从_branchcr获取未入库的CR
_makeota=no			# 是否生成OTA包
_makeclean=no		# 编译android是，是否清空中间件
_lunchsku=${_lunchsku:-no}			# 是否加载sku参数，编译rk3288分支时，该参数请设为 no
_prebuildapp=${_prebuildapp:-no}		# 是否预编译集成App，编译rk3288分支时，该参数请设为 no
# _verifiedfb=${_verifiedfb:-yes}		# 编译验证反馈给Gerrit
# _tempfile=${_tempfile:-temp.txt}		# 临时文件，主要用于临时存储Gerrit上的相关CR
_svn_server_pdir="none"  	# 内部SVN上传地址，为 none 时，不上传
_svn_server_pdir_qa="none" 	# QA的SVN上传地址，为 none 时，不上传


source ${JENKINS_HOME}/jobscripts/nd3_make.sh

