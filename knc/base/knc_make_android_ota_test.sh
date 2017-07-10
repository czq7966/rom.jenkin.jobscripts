if [ "${_makeota}" == "yes" ]; then
	echo "******生成 全量包、完整包、增量包******"

	WORKSPACE=${WORKSPACE:-.}
	BUILDPATH=${BUILDPATH:-${WORKSPACE}}
	UPDATEPATH=${UPDATEPATH:-${BUILDPATH}/RKTools/windows/AndroidTool/AndroidTool_Release_v2.33/rockdev}

	# 定义输出目录
	_output_dir="${_output_dir:-${UPDATEPATH}/output}"
	_tfp_dir=${_tfp_dir:-${_output_dir}/ota/tfp}
	_tfp4inc_dir=${_tfp4inc_dir:-${_output_dir}/ota/tfp4inc}

	# 递增版本号，再次生成增量包
	let BUILD_NUMBER=$((${BUILD_NUMBER}+1))
	echo "BUILD_NUMBER=$BUILD_NUMBER"

	cd $BUILDPATH
	source build/envsetup.sh
	lunch ${_product}-${_variant}-${_nettype}-${_device}-${_sku}
	echo "test.ota.test.date=`date +%Y%m%d-%H%M`" >> device/rockchip/${_product}/system.prop
	make -j8
	source mkimage.sh ${_product} ota


	mkdir -p ${_tfp4inc_dir}
	scp -r ${_tfp_dir}/.  ${_tfp4inc_dir}/.  

	cd $BUILDPATH
	make nd_otapackage_inc -j8
fi
