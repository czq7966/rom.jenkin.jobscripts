cd $WORKSPACE/android4.4

_project=nd2x
_branch=rel
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
_targetfilename=${TARGET_USERS_DEVICE}_${TARGET_USERS_SKU}_${TARGET_BUILD_VARIANT}-${CURRENT_GIT_BRANCH}-${TARGET_NET_TYPE}-${CURRENT_GIT_BRANCH_SHA}_`date +%Y%m%d-%H%M`_v${RO_PRODUCT_FIRMWARE_VERSION}.${RO_PRODUCT_FIRMWARE_PACK_NUMBER}.img

_targetdir="$WORKSPACE/output/img"
_sharedir=" /home/192.168.51.38/pub/nd2x/nd刷机包/${_branch}分支/${_variant}版"

mkdir -p ${_targetdir}
mv ${_sourcefilename} ${_targetdir}/${_targetfilename}
echo  " ${_targetdir}/${_targetfilename}"
scp   ${_targetdir}/${_targetfilename}  ${_sharedir}/${_targetfilename}  
echo  " ${_sharedir}/${_targetfilename}  "





