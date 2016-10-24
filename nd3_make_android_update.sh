echo "******生成刷机包******"
WORKSPACE=${WORKSPACE:-.}
UPDATEPATH=${UPDATEPATH:-${WORKSPACE}/RKTools/windows/AndroidTool/AndroidTool_Release_v2.33/rockdev}

# 定义输出目录及包名
_output_dir="$UPDATEPATH/output"
_versionname=${RO_PRODUCT_FIRMWARE_VERSION}.${RO_PRODUCT_FIRMWARE_PACK_NUMBER}
_sourcefilename="$UPDATEPATH/update.img"
_targetfilename=${_targetfilename:-${TARGET_USERS_DEVICE}_${TARGET_USERS_SKU}_${TARGET_BUILD_VARIANT}-${CURRENT_GIT_BRANCH}-${TARGET_NET_TYPE}-${CURRENT_GIT_BRANCH_SHA}_`date +%Y%m%d-%H%M`_v${_versionname}}
_targetfileimg=${_targetfilename}.img
_img_dir=${_output_dir}/img

# 生成刷机包
cd $UPDATEPATH
source mkupdate.sh
rm -rf ${_img_dir}
mkdir -p ${_img_dir}
mv ${_sourcefilename} ${_img_dir}/${_targetfileimg}
echo  "已生成刷机包 ${_img_dir}/${_targetfileimg}"

