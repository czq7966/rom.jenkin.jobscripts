if [ "${_makeota}" == "yes" ]; then
	echo "******生成 全量包、完整包、增量包******"

	WORKSPACE=${WORKSPACE:-.}
	BUILDPATH=${BUILDPATH:-${WORKSPACE}}
	UPDATEPATH=${UPDATEPATH:-${BUILDPATH}/RKTools/windows/AndroidTool/rockdev}
	# 生成drmsigntool工具
	cd $BUILDPATH/build/tools/drmsigntool
	mm -B
	cd $BUILDPATH/build/tools/remkloader
	mm -B
	cd $BUILDPATH/build/tools/mkparameter
	mm -B
	
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
	# echo "******生成 全量包******"
	# make nd_target-files-package -j8
	echo "******生成 卡刷包 全量包******"
	make nd_otapackage -j8
	echo "******生成 增量包******"
	make nd_otapackage_inc -j8
fi

