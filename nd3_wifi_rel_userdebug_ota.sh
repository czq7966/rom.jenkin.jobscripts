# 参数默认值 代码相关
# 默认库名
# _project=${_project:-rom/nd3}
_branchver=rel
_branchcode=rel
_branchcr=rel
# 临时从哪个分支上过来，是merge操作
# _branchmerge=${_branchmerge:-}
# _branchpick=${_branchpick:-}			# 临时从哪个CR上pick过来
_variant=userdebug
# _product=${_product:-nd3}			# 产品：nd3 nd2x
# _nettype=${_nettype:-wifi}			# 网络支持：wifi 4g
# _device=${_device:-ND3}			# 设备：ND3
_sku=CN

# 参数默认值 编译相关
_pickcr=no
# _makeota=${_makeota:-yes}			# 是否生成OTA包
# _makeclean=${_makeclean:-yes}			# 编译android是，是否清空中间件
# _verifiedfb=${_verifiedfb:-yes}		# 编译验证反馈给Gerrit
# _lunchsku=${_lunchsku:-yes}			# 是否加载sku参数，编译rk3288分支时，该参数请设为 no
# _prebuildapp=${_prebuildapp:-yes}		# 是否预编译集成App，编译rk3288分支时，该参数请设为 no
# _tempfile=${_tempfile:-temp.txt}		# 临时文件，主要用于临时存储Gerrit上的相关CR
_svn_server_pdir="https://192.168.19.238/svn/101PAD/ROM包/nd3/发布包"
# _svn_server_pdir_qa="${_svn_server_pdir_qa:-https://192.168.160.4:8443/svn/101pad/待测试/ROM/nd3}" 	# QA的SVN上传地址，为 none 时，不上传


source ${JENKINS_HOME}/jobscripts/nd3_make.sh




