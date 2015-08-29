#WORKSPACE=/var/lib/jenkins/jobs/nd2x_wifi_rel_userdebug_ota/workspace
#let BUILD_NUMBER=33
let BUILD_NUMBER=$((${BUILD_NUMBER}+1))
echo "BUILD_NUMBER=$BUILD_NUMBER"

echo $WORKSPACE
cd $WORKSPACE/android4.4

_project=nd2x
_branch=rel
_variant=userdebug
_product=fiber_a31stm
_nettype=wifi
_device=ND2X
_sku=CN

#git fetch
#git reset --hard origin/${_branch}
git checkout -B ${_branch} origin/${_branch}


source build/envsetup.sh
lunch ${_product}-${_variant}-${_nettype}-${_device}-${_sku}
#make clean
#extract-bsp
#make update-api
#make recoveryimage -j8 -B
echo "test.ota.test.date=`date +%Y%m%d-%H%M`" >> device/softwinner/fiber-a31stm/system.prop
make -j8


#_sourcefilename="$WORKSPACE/lichee/tools/pack_brandy/sun6i_android_fiber-a31stm.img"
#_targetfilename=${TARGET_USERS_DEVICE}_${TARGET_BUILD_VARIANT}-${CURRENT_GIT_BRANCH}-${TARGET_NET_TYPE}-${CURRENT_GIT_BRANCH_SHA}_`date +%Y%m%d-%H%M`_v${RO_PRODUCT_FIRMWARE_VERSION}.${RO_PRODUCT_FIRMWARE_PACK_NUMBER}
#_targetfileimg=${_targetfilename}.img


_output_dir="$WORKSPACE/output"
_img_dir=${_output_dir}/img


_tfp_dir=${_output_dir}/ota/tfp
_tfp4inc_dir=${_output_dir}/ota/tfp4inc
scp -r ${_tfp_dir}/.  ${_tfp4inc_dir}/.  
 
get_uboot
make nd_otapackage_inc

#_share_ota_dir=" /home/192.168.51.38/pub/nd2x/ota包/${_targetfilename}"
#mkdir -p ${_share_ota_dir}
#scp -r ${_output_dir}/.  ${_share_ota_dir}/.  


