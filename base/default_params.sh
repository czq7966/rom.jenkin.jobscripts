echo "******加载参数******"
# 执行命令行参数　如: name=value , #号代码空格
for v in $@ 
do
	echo "${v//#/ }" 
 	eval "${v//#/ }" 
done
echo "******执行命令行参数完毕******"
# 参数默认值 代码相关
# _project=${_project:-rom/nd3}　　	 	# 默认库名
# _branchver=${_branchver:-test}　		# 版本分支，现有:dev rel int test tibet_dev tibet_rel english_dev english_rel
# _branchcode=${_branchcode:-test}		# 代码分支
# _branchcr=${_branchcr:-${_branchcode} dev}	# 合并分支，后面的分支rebase到前面的分支，是rebase操作
# _branchmerge=${_branchmerge:-}		# 临时从哪个分支上过来，是merge操作
# _branchpick=${_branchpick:-}			# 临时从哪个CR上pick过来
# _variant=${_variant:-userdebug}		# user/userdebug
# _product=${_product:-nd3}				# 产品：nd3 nd2x 
# _nettype=${_nettype:-wifi}			# 网络支持：wifi 4g
# _device=${_device:-ND3}				# 设备：ND3
# _sku=${_sku:-CN_${_branchcode}}		# 区域码：CN

# 参数默认值 编译相关
# _mergestrategy=${_pickcr:-rebase}		# 合并策略 是 rebase 还是　merge
# _pickcr=${_pickcr:-yes}				# 是否从_branchcr获取未入库的CR
# _makeota=${_makeota:-yes}				# 是否生成OTA包
# _makeclean=${_makeclean:-yes}			# 编译android是，是否清空中间件
# _verifiedfb=${_verifiedfb:-yes}		# 编译验证反馈给Gerrit
# _lunchsku=${_lunchsku:-yes}			# 是否加载sku参数，编译rk3288分支时，该参数请设为 no
# _prebuildapp=${_prebuildapp:-yes}		# 是否预编译集成App，编译rk3288分支时，该参数请设为 no
# _tempfile=${_tempfile:-temp.txt}		# 临时文件，主要用于临时存储Gerrit上的相关CR
# _svn_server_pdir="${_svn_server_pdir:-https://192.168.19.238/svn/101PAD/ROM包/nd3/临时测试包}"  		# 内部SVN上传地址，为 none 时，不上传
# _svn_server_pdir_qa="${_svn_server_pdir_qa:-https://192.168.160.4:8443/svn/101pad/待测试/ROM/nd3}" 	# QA的SVN上传地址，为 none 时，不上传
# _ftp_server_pdir_qa="${_ftp_server_pdir_qa:-192.168.160.4/nd3}" 										# QA的SVN上传地址，为 none 时，不上传

_project=${_project:-rom/nd3}
_branchver=${_branchver:-test}
_branchcode=${_branchcode:-test}
_branchcr=${_branchcr:-${_branchcode} dev}
_branchmerge=${_branchmerge:-}
_branchpick=${_branchpick:-}
_variant=${_variant:-userdebug}
_product=${_product:-nd3}
_nettype=${_nettype:-wifi}
_device=${_device:-ND3}
_sku=${_sku:-CN_${_branchcode}}

_mergestrategy=${_mergestrategy:-merge}	
_pickcr=${_pickcr:-yes}
_makeota=${_makeota:-yes}
_makeclean=${_makeclean:-yes}
_lunchsku=${_lunchsku:-yes}
_prebuildapp=${_prebuildapp:-yes}
_verifiedfb=${_verifiedfb:-yes}
_tempfile=${_tempfile:-temp.txt}
_svn_server_pdir="${_svn_server_pdir:-https://192.168.19.238/svn/101PAD/ROM包/nd3/临时测试包}"
_svn_server_pdir_qa="${_svn_server_pdir_qa:-https://192.168.160.4:8443/svn/101pad/待测试/ROM/nd3}"
_ftp_server_pdir_qa="${_ftp_server_pdir_qa:-192.168.160.4/nd3}" 

echo "_project=${_project}"
echo "_branchver=$_branchver"
echo "_branchcode=$_branchcode"
echo "_branchcr=${_branchcr[@]}"
echo "_branchmerge=$_branchmerge"
echo "_branchpick=$_branchpick"
echo "_variant=$_variant"
echo "_product=$_product"
echo "_nettype=$_nettype"
echo "_device=$_device"
echo "_sku=$_sku"
echo "_mergestrategy=$_mergestrategy"
echo "_pickcr=$_pickcr"
echo "_makeota=$_makeota"
echo "_makeclean=$_makeclean"
echo "_lunchsku=$_lunchsku"
echo "_prebuildapp=$_prebuildapp"
echo "_verifiedfb=$_verifiedfb"
echo "_tempfile=$_tempfile"
echo "_svn_server_pdir=$_svn_server_pdir"
echo "_svn_server_pdir_qa=$_svn_server_pdir_qa"
echo "_ftp_server_pdir_qa=$_ftp_server_pdir_qa"

