cd $WORKSPACE
UPDATEPATH=$WORKSPACE/RKTools/windows/AndroidTool/AndroidTool_Release_v2.33/rockdev

_project=nd3
_branchver=test
_branchcr=(dev test_itgapps)
_branchcode=test_itgapps
_variant=user
_product=nd3
_nettype=wifi
_device=ND3
_sku=CN_itgapps


source ${JENKINS_HOME}/jobscripts/base_functions.sh


git clean -fd
git fetch
git reset --hard origin/${_branchcode}
git checkout -B ${_branchver} origin/${_branchcode}

temp_file=temp.txt
> $temp_file
gerrit_query_open ${temp_file} ${_project} ${_branchcr[@]} 


unset ids
unset ids2
for _branchcur in ${_branchcr[@]}  
do
	evalStr="cat $temp_file | jq 'select(.branch == \"${_branchcur}\")' | jq 'select(.number != null)' | jq '.number | tonumber'"
	ids=(`eval $evalStr`)
	idssort=( $(for val in "${ids[@]}"  
	do 
	 echo "$val" 
	done | sort -n) ) 
	gerrit_review $temp_file 0 ${idssort[@]}	
	git_cherry_pick $temp_file $_branchcur ${idssort[@]}
	ids2=(${ids2[@]} ${idssort[@]})
done 

echo "${ids2[@]}"


git_rebase_branch ${_branchcr[@]}


git checkout -B ${_branchver} ${_branchcode}
# 编译u-boot
cd $WORKSPACE/u-boot
make distclean
make rk3288_defconfig
make -j4
rm $UPDATEPATH/RK3288UbootLoader_V2.19.07.bin
scp $WORKSPACE/u-boot/RK3288UbootLoader_V2.19.07.bin $UPDATEPATH/RK3288UbootLoader_V2.19.07.bin

# 编译kernel
cd $WORKSPACE/kernel
make distclean
make rockchip_nd3_defconfig
make rk3288-tb.img -j8


# 编译Android
cd $WORKSPACE
source build/envsetup.sh
lunch ${_product}-${_variant}-${_nettype}-${_device}-${_sku}
make clean
if [ ! -f "out/host/linux-x86/bin/aapt" ]; then  
	echo "×××××××××××××××××××××编译aapt工具***********************"
	make clean
	make update-api
	make aapt -j8
fi 

# 按规则生成集成App
echo "×××××××××××××××××××××开始生成要集成的Apps***********************"
cd $WORKSPACE/device/rockchip/nd3/nd/common/packages/prebuilds
source generate.sh

cd $WORKSPACE
make update-api
make -j8
source mkimage.sh ota

# 生成刷机包
cd $UPDATEPATH
source mkupdate.sh


cd $WORKSPACE
gerrit_review $temp_file 1 ${ids2[@]}


rm $temp_file


# 定义输出目录
_output_dir="$UPDATEPATH/output"
_versionname=${RO_PRODUCT_FIRMWARE_VERSION}.${RO_PRODUCT_FIRMWARE_PACK_NUMBER}
_sourcefilename="$UPDATEPATH/update.img"
_targetfilename=${TARGET_USERS_DEVICE}_${TARGET_USERS_SKU}_${TARGET_BUILD_VARIANT}-${CURRENT_GIT_BRANCH}-${TARGET_NET_TYPE}-${CURRENT_GIT_BRANCH_SHA}_`date +%Y%m%d-%H%M`_v${_versionname}
_targetfileimg=${_targetfilename}.img
_img_dir=${_output_dir}/img

rm -rf ${_img_dir}
mkdir -p ${_img_dir}
mv ${_sourcefilename} ${_img_dir}/${_targetfileimg}
echo  " ${_img_dir}/${_targetfileimg}"

# 复制到共享服务器
_share_ota_dir=" /home/192.168.4.177/pub/nd3/专项测试包/${_targetfilename}"
mkdir -p ${_share_ota_dir}
scp -r ${_output_dir}/.  ${_share_ota_dir}/.  

# 上传至SVN
_svn_server_dir="https://192.168.160.4:8443/svn/101pad/待测试/ROM/nd3/${TARGET_USERS_SKU}_${TARGET_NET_TYPE}-v${_versionname}/${_targetfilename}"
_svn_local_dir="${_output_dir}"
_svn_message="${_targetfilename}"
_svn_username=czq761208
_svn_password=761208

svn mkdir  ${_svn_server_dir} -m ${_svn_message} --username ${_svn_username} --password ${_svn_password} --parents 2>&1
svn import ${_svn_local_dir} ${_svn_server_dir} -m ${_svn_message} --username ${_svn_username} --password ${_svn_password}  






