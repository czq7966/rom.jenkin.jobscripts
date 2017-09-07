# 参数默认值 代码相关
# _project=${_project:-rom/nd3}　　	 	# 默认库名
# _branchver=${_branchver:-test}　		# 版本分支，现有:dev rel int test tibet_dev tibet_rel english_dev english_rel
_branchver=knc_rel
# _branchcode=${_branchcode:-test}		# 代码分支
_branchcode=knc_rel
# _branchcr=${_branchcr:-dev ${_branchcode}}	# 合并分支，后面的分支rebase到前面的分支
_branchcr=knc_rel
# _branchmerge=${_branchmerge:-}		# 临时从哪个分支上过来，是merge操作
# _branchpick=${_branchpick:-}			# 临时从哪个CR上pick过来
# _variant=${_variant:-userdebug}		# user/userdebug
_variant=userdebug
# _product=${_product:-KNC_D9}			# 产品：nd3 nd2x
# _nettype=${_nettype:-wifi}			# 网络支持：wifi 4g
# _device=${_device:-KNC_D9}			# 设备：ND3
# _sku=${_sku:-CN_${_branchcode}}		# 区域码：CN
_sku=CN

# 参数默认值 编译相关
# _pickcr=${_pickcr:-yes}			# 是否从_branchcr获取未入库的CR
# _makeota=${_makeota:-yes}			# 是否生成OTA包
# _makeclean=yes
# _verifiedfb=${_verifiedfb:-yes}		# 编译验证反馈给Gerrit
# _tempfile=${_tempfile:-temp.txt}		# 临时文件，主要用于临时存储Gerrit上的相关CR
# _svn_server_pdir="none"
_svn_server_pdir="${_svn_server_pdir:-https://192.168.19.238/svn/101PAD/ROM包/knc/预备发布包}"
# _svn_server_pdir_qa="none"


source ${JENKINS_HOME}/jobscripts/knc/base/knc_make.sh


