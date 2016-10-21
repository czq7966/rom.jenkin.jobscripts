echo "******加载参数******"
# 执行命令行参数　如: name=value , #号代码空格
for v in $@ 
do
 	eval "${v//#/ }" 
done

# 参数默认值 代码相关
# _project=${_project:-rom/nd3}　　	 	默认库名
# _branchver=${_branchver:-test}　		版本分支，现有:dev rel int test tibet_dev tibet_rel english_dev english_rel
# _branchcode=${_branchcode:-test}		代码分支
# _branchcr=${_branchcr:-dev ${_branchcode}}	合并分支，后面的分支rebase到前面的分支
# _branchpick=${_branchpick:-}			临时从哪个CR上pick过来
# _variant=${_variant:-userdebug}		user/userdebug
# _product=${_product:-nd3}			产品：nd3 nd2x
# _nettype=${_nettype:-wifi}			网络支持：wifi 4g
# _device=${_device:-ND3}			设备：ND3
# _sku=${_sku:-CN_${_branchcode}}		区域码：CN

# 参数默认值 编译相关
# _makeclean=${_makenoclean:-yes}		编译android是，是否清空中间件
# _verifiedfb=${_verifiedfb:-yes}		编译验证反馈给Gerrit
#_tempfile=${_tempfile:-temp.txt}		临时文件，主要用于临时存储Gerrit上的相关CR

_project=${_project:-rom/nd3}
_branchver=${_branchver:-test}
_branchcode=${_branchcode:-test}
_branchcr=${_branchcr:-dev ${_branchcode}}
_branchpick=${_branchpick:-}
_variant=${_variant:-userdebug}
_product=${_product:-nd3}
_nettype=${_nettype:-wifi}
_device=${_device:-ND3}
_sku=${_sku:-CN_${_branchcode}}

_makeclean=${_makeclean:-yes}
_verifiedfb=${_verifiedfb:-yes}
_tempfile=${_tempfile:-temp.txt}

echo "_project=${_project}"
echo "_branchver=$_branchver"
echo "_branchcode=$_branchcode"
echo "_branchcr=${_branchcr[@]}"
echo "_branchpick=$_branchpick"
echo "_variant=$_variant"
echo "_product=$_product"
echo "_nettype=$_nettype"
echo "_device=$_device"
echo "_sku=$_sku"
echo "_makeclean=$_makeclean"
echo "_verifiedfb=$_verifiedfb"
echo "_tempfile=$_tempfile"
