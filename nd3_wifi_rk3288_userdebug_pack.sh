cd $WORKSPACE
UPDATEPATH=$WORKSPACE/RKTools/windows/AndroidTool/AndroidTool_Release_v2.33/rockdev

_project=rom/nd3
_branchver=rk3288
_branchcr=(rk3288)
_branchcode=rk3288
_branchmerge=rk3288_merge
_branchpick=(50d29102bc2a1994b14a020255f4bea5df1edf60)
_variant=userdebug
_product=rk3288
_nettype=wifi
_device=ND3
_sku=CN


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




git merge origin/${_branchmerge}
for _pick in ${_branchpick[@]}  
do 
	git cherry-pick ${_pick}
done




cd $WORKSPACE/u-boot
make distclean
make rk3288_defconfig
make -j4
rm  $UPDATEPATH/RK3288UbootLoader_V*.bin
cp $WORKSPACE/u-boot/RK3288UbootLoader_V*.bin $UPDATEPATH/

cd $WORKSPACE/kernel
make distclean
make rockchip_nd3_defconfig
make rk3288-tb.img -j8

cd $WORKSPACE
source build/envsetup.sh
lunch ${_product}-${_variant}
make clean
make update-api
make -j8
source mkimage.sh ota

# pack the charge pictures to resource.img
#cd $WORKSPACE/u-boot
#if [ -f ../kernel/resource.img ]; then
#    echo -e "\n\033[44;31;5mPack and Copy the images:\033[0m"
#    tools/resource_tool/pack_resource.sh tools/resource_tool/resources/ ../kernel/resource.img resource.img tools/resource_tool/resource_tool

#    echo ""
#    cp -v  resource.img $UPDATEPATH/Image/
#fi

cd $UPDATEPATH
source mkupdate.sh

line=`git rev-parse origin/${_branchcode}`
CURRENT_GIT_BRANCH_SHA=${line:0:7}

_sourcefilename="$UPDATEPATH/update.img"
_targetfilename=${TARGET_PRODUCT}_${TARGET_BUILD_VARIANT}-${_branchcode}-${CURRENT_GIT_BRANCH_SHA}_`date +%Y%m%d-%H%M`
_targetfileimg=${_targetfilename}.img


# 复制到共享服务器
_share_ota_dir=" /home/192.168.51.38/pub/nd3/RK测试包"
mkdir -p ${_share_ota_dir}
scp -r ${_sourcefilename}  ${_share_ota_dir}/${_targetfileimg}

# 上传至SVN
_svn_server_dir="https://192.168.160.4:8443/svn/101pad/待测试/ROM/nd3/RK测试包"
_svn_server_file="${_svn_server_dir}/${_targetfileimg}"
_svn_local_dir="${UPDATEPATH}"
_svn_local_file="${_sourcefilename}"
_svn_message="${_targetfilename}"
_svn_username=czq761208
_svn_password=761208

#svn mkdir  ${_svn_server_dir} -m ${_svn_message} --username ${_svn_username} --password ${_svn_password} --parents 2>&1
#svn import ${_svn_local_file} ${_svn_server_file} -m ${_svn_message} --username ${_svn_username} --password ${_svn_password}  

cd $WORKSPACE
gerrit_review $temp_file 1 ${ids2[@]}

rm $temp_file


