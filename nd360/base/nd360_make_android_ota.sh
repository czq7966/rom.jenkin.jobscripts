if [ "${_makeota}" == "yes" ]; then
	echo "******生成 全量包、完整包、增量包******"

	WORKSPACE=${WORKSPACE:-.}
	BUILDPATH=${BUILDPATH:-${WORKSPACE}}
	UPDATEPATH=${UPDATEPATH:-${BUILDPATH}/RKTools/windows/AndroidTool/rockdev}
	cd $BUILDPATH
	# 定义输出目录
	_output_dir="${_output_dir:-${UPDATEPATH}/output}"

	# 生成 全量包、完整包、增量包
	_tfp_dir=${_output_dir}/ota/tfp
	_inc_dir=${_output_dir}/ota/inc
	_opt_dir=${_output_dir}/ota/opt
	_tfp4inc_dir=${_output_dir}/ota/tfp4inc
	rm -rf ${_tfp_dir}
	rm -rf ${_inc_dir}
	rm -rf ${_opt_dir}
	make nd_target-files-package -j8
	make nd_otapackage -j8
	make nd_otapackage_inc -j8
fi

