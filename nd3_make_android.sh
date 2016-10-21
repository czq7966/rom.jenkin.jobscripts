echo "******编译 nd3 Android******"
# 编译Android
# 编译Android
WORKSPACE=${WORKSPACE:-.}
UPDATEPATH=${UPDATEPATH:-${WORKSPACE}/RKTools/windows/AndroidTool/AndroidTool_Release_v2.33/rockdev}

cd $WORKSPACE
source build/envsetup.sh
lunch ${_product}-${_variant}-${_nettype}-${_device}-${_sku}
if [ "${_makeclean}" == "yes" ]; then
	make clean
fi
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

