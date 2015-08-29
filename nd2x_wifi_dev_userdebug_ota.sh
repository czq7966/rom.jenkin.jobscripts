cd $WORKSPACE/android4.4

_project=nd2x
_branch=dev
_variant=userdebug
_product=fiber_a31stm
_nettype=wifi
_device=ND2X
_sku=CN

git fetch
git reset --hard origin/${_branch}
git checkout -B ${_branch} origin/${_branch}

source build/envsetup.sh
lunch ${_product}-${_variant}-${_nettype}-${_device}-${_sku}
make clean
extract-bsp
make update-api
make -j8
pack

_sourcefilename="$WORKSPACE/lichee/tools/pack_brandy/sun6i_android_fiber-a31stm.img"
_targetfilename=${TARGET_USERS_DEVICE}_${TARGET_USERS_SKU}_${TARGET_BUILD_VARIANT}-${CURRENT_GIT_BRANCH}-${TARGET_NET_TYPE}-${CURRENT_GIT_BRANCH_SHA}_`date +%Y%m%d-%H%M`_v${RO_PRODUCT_FIRMWARE_VERSION}.${RO_PRODUCT_FIRMWARE_PACK_NUMBER}
_targetfileimg=${_targetfilename}.img


_output_dir="$WORKSPACE/output"
_img_dir=${_output_dir}/img

rm -rf ${_img_dir}
mkdir -p ${_img_dir}
mv ${_sourcefilename} ${_img_dir}/${_targetfileimg}
echo  " ${_img_dir}/${_targetfileimg}"

_tfp_dir=${_output_dir}/ota/tfp
_int_dir=${_output_dir}/ota/inc
rm -rf ${_tfp_dir}
rm -rf ${_int_dir}

get_uboot
make nd_otapackage_inc

_share_ota_dir=" /home/192.168.51.38/pub/nd2x/发布包/${_targetfilename}"
mkdir -p ${_share_ota_dir}
scp -r ${_output_dir}/.  ${_share_ota_dir}/.  


