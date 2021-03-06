echo "******编译 nd3 Android******"
# 编译Android
WORKSPACE=${WORKSPACE:-.}
BUILDPATH=${BUILDPATH:-${WORKSPACE}}
UPDATEPATH=${UPDATEPATH:-${BUILDPATH}/RKTools/windows/AndroidTool/AndroidTool_Release_v2.33/rockdev}

cd $BUILDPATH
source build/envsetup.sh
if [ "${_lunchsku}" == "yes" ]; then
	lunch ${_product}-${_variant}-${_nettype}-${_device}-${_sku}
else
	lunch ${_product}-${_variant}
fi
if [ "${_makeclean}" == "yes" ]; then
	echo "******执行 make clean ******"
	make clean
fi
if [ "${_prebuildapp}" == "yes" ]; then
	if [ ! -f "out/host/linux-x86/bin/aapt" ]; then  
		echo "×××××××××××××××××××××编译aapt工具***********************"
		make clean
		make update-api
		make aapt -j8
	fi 
	# 按规则生成集成App
	echo "×××××××××××××××××××××开始生成要集成的Apps***********************"
	cd ${BUILDPATH}/device/rockchip/nd3/nd/common/packages/prebuilds
	source generate.sh
fi

cd $BUILDPATH
make update-api
make -j8
source mkimage.sh ota

