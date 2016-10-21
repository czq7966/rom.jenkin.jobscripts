cd $WORKSPACE
UPDATEPATH=$WORKSPACE/RKTools/windows/AndroidTool/AndroidTool_Release_v2.33/rockdev
JOBSCRIPTSPATH=${JENKINS_HOME}/jobscripts


# 参数默认值，可从命令行输入，格式如： name=value , #号代码空格
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
# _makeclean=${_makenoclean:-yes}		编译android是，是否清空中间件
# _verifiedfb=${_verifiedfb:-yes}		编译验证反馈给Gerrit

_makeclean=no
# 加载参数
source ${JOBSCRIPTSPATH}/default_params.sh
# 加载与Gerrit通信的自定义函数
source ${JOBSCRIPTSPATH}/base_functions.sh
# 准备代码
source ${JOBSCRIPTSPATH}/prepare_code.sh
# 编译u-boot
source ${JOBSCRIPTSPATH}/nd3_make_uboot.sh
# 编译kernel
source ${JOBSCRIPTSPATH}/nd3_make_kernel.sh
# 编译Android
source ${JOBSCRIPTSPATH}/nd3_make_android.sh
# 生成刷机包
source ${JOBSCRIPTSPATH}/nd3_make_android_update.sh
# 生成OTA包
source ${JOBSCRIPTSPATH}/nd3_make_android_ota.sh
# 生成测试OTA包
source ${JOBSCRIPTSPATH}/nd3_make_android_ota_test.sh
# 上传至部门内SVN
_svn_server_pdir="https://192.168.19.238/svn/101PAD/ROM包/nd3/临时测试包"
source ${JOBSCRIPTSPATH}/import_to_svn.sh
# 上传至QA的SVN
_svn_server_pdir="https://192.168.160.4:8443/svn/101pad/待测试/ROM/nd3"
source ${JOBSCRIPTSPATH}/import_to_qa_svn.sh
# 编译反馈成功
source ${JOBSCRIPTSPATH}/feedback_succeed.sh





