cd $WORKSPACE
UPDATEPATH=$WORKSPACE/RKTools/windows/AndroidTool/AndroidTool_Release_v2.33/rockdev

for v in $@ 
do
 	eval "${v//#/ }" 
done

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

source ${JENKINS_HOME}/jobscripts/base_functions.sh

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



git clean -fd
git fetch
git reset --hard origin/${_branchcode}
git checkout -B ${_branchver} origin/${_branchcode}
exit
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

for _pick in ${_branchpick[@]}  
do 
	git cherry-pick ${_pick}
done

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


