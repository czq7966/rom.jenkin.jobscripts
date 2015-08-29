cd $WORKSPACE
UPDATEPATH=$WORKSPACE/RKTools/windows/AndroidTool/AndroidTool_Release_v2.33/rockdev

_project=nd3
_branchver=rel
_branchcr=(rel)
_branchcode=rel
_variant=userdebug
_product=nd3
_nettype=wifi
_device=ND3
_sku=CN


git clean -fd
git fetch
git reset --hard origin/${_branchcode}
git checkout -B ${_branchver} origin/${_branchcode}


cd $WORKSPACE/u-boot
make distclean
make rk3288_defconfig
make -j4

cd $WORKSPACE/kernel
make distclean
make rockchip_nd3_defconfig
make rk3288-tb.img -j8

cd $WORKSPACE
source build/envsetup.sh
lunch ${_product}-${_variant}-${_nettype}-${_device}-${_sku}
make clean
make update-api
make -j8

rm -f $UPDATEPATH/Image/* 
source mkimage.sh ota

rm $UPDATEPATH/RK3288UbootLoader_V2.19.07.bin
scp $WORKSPACE/u-boot/RK3288UbootLoader_V2.19.07.bin $UPDATEPATH/RK3288UbootLoader_V2.19.07.bin

cd $UPDATEPATH
source mkupdate.sh

_sourcefilename="$UPDATEPATH/update.img"
_targetfilename=${TARGET_USERS_DEVICE}_${TARGET_USERS_SKU}_${TARGET_BUILD_VARIANT}-${CURRENT_GIT_BRANCH}-${TARGET_NET_TYPE}-${CURRENT_GIT_BRANCH_SHA}_`date +%Y%m%d-%H%M`_v${RO_PRODUCT_FIRMWARE_VERSION}.${RO_PRODUCT_FIRMWARE_PACK_NUMBER}
_targetfileimg=${_targetfilename}.img

_output_dir="$UPDATEPATH/output"
_img_dir=${_output_dir}/img

rm -rf ${_img_dir}
mkdir -p ${_img_dir}
mv ${_sourcefilename} ${_img_dir}/${_targetfileimg}
echo  " ${_img_dir}/${_targetfileimg}"

_tfp_dir=${_output_dir}/ota/tfp
_int_dir=${_output_dir}/ota/inc
rm -rf ${_tfp_dir}
rm -rf ${_int_dir}

cd $WORKSPACE
make nd_otapackage_inc -j8

_share_ota_dir=" /home/192.168.51.38/pub/nd3/发布包/${_targetfilename}"
mkdir -p ${_share_ota_dir}
scp -r ${_output_dir}/.  ${_share_ota_dir}/.  

_svn_server_dir="https://192.168.160.4:8443/svn/101pad/待测试/ROM/nd3/${TARGET_NET_TYPE}-v${RO_PRODUCT_FIRMWARE_VERSION}.${RO_PRODUCT_FIRMWARE_PACK_NUMBER}/${_targetfilename}"
_svn_local_dir="${_output_dir}"
_svn_message="${_targetfilename}"
_svn_username=czq761208
_svn_password=761208

svn mkdir  ${_svn_server_dir} -m ${_svn_message} --username ${_svn_username} --password ${_svn_password}  --force
svn import ${_svn_local_dir} ${_svn_server_dir} -m ${_svn_message} --username ${_svn_username} --password ${_svn_password}  --force





