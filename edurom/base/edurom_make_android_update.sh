WORKSPACE=${WORKSPACE:-.}
BUILDPATH=${BUILDPATH:-${WORKSPACE}}
UPDATEPATH=${UPDATEPATH:-${BUILDPATH}}

# 定义输出目录及包名
_output_dir="$UPDATEPATH/output"
_versionname=${RO_PRODUCT_FIRMWARE_VERSION}.${RO_PRODUCT_FIRMWARE_PACK_NUMBER}
_sourcefilename="$UPDATEPATH/update.img"
_targetfilename=${_targetfilename:-${TARGET_USERS_DEVICE}_${TARGET_USERS_SKU}_${TARGET_BUILD_VARIANT}-${CURRENT_GIT_BRANCH}-${TARGET_NET_TYPE}-${CURRENT_GIT_BRANCH_SHA}_`date +%Y%m%d-%H%M`_v${_versionname}}
_targetfileimg=${_targetfilename}.img
_img_dir=${_output_dir}/img

# 暂无img包的生成方法，先用卡刷包为img(请先执行edurom_make_android_ota.sh脚本)
_opt_dir=${_output_dir}/ota/opt
if [ -d "${_opt_dir}" ]; then
	echo "******生成刷机包******"
	cd $_opt_dir
	_sourcefilename=`ls`
	_targetfileimg=${_targetfilename}.zip

	# 生成刷机包
	if [ -f "${_sourcefilename}" ]; then
		rm -rf ${_img_dir}
		mkdir -p ${_img_dir}
		cp ${_sourcefilename} ${_img_dir}/${_targetfileimg}
		echo  "已生成刷机包 ${_img_dir}/${_targetfileimg}"
	fi
	
	#复制各种img分区包
	cd $ANDROID_PRODUCT_OUT
	_imgfiles=`ls *.img`
	for _file in $_imgfiles
	do
		cp ${_file} ${_img_dir}/${_file}
	done
fi

