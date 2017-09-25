echo "******编译 nd2x Android******"
# 编译Android
WORKSPACE=${WORKSPACE:-.}
BUILDPATH=${BUILDPATH:-${WORKSPACE}/android4.4}

cd $BUILDPATH
source build/envsetup.sh
lunch ${_product}-${_variant}-${_nettype}-${_device}-${_sku}
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
	cd ${BUILDPATH}
	source integrates.sh
fi
cd $BUILDPATH
extract-bsp
make update-api
make -j8
pack
