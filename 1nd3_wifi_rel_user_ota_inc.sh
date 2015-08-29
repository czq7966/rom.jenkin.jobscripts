let BUILD_NUMBER=$((${BUILD_NUMBER}+1))
echo "BUILD_NUMBER=$BUILD_NUMBER"

cd $WORKSPACE
UPDATEPATH=$WORKSPACE/RKTools/windows/AndroidTool/AndroidTool_Release_v2.33/rockdev

_project=nd3
_branchver=rel
_branchcr=(rel)
_branchcode=rel
_variant=user
_product=nd3
_nettype=wifi
_device=ND3
_sku=CN

git checkout -B ${_branchver} origin/${_branchcode}

cd $WORKSPACE
source build/envsetup.sh
lunch ${_product}-${_variant}-${_nettype}-${_device}-${_sku}
echo "test.ota.test.date=`date +%Y%m%d-%H%M`" >> device/rockchip/nd3/system.prop
make -j8
source mkimage.sh ota


_output_dir="$UPDATEPATH/output"
_tfp_dir=${_output_dir}/ota/tfp
_tfp4inc_dir=${_output_dir}/ota/tfp4inc
mkdir -p ${_tfp4inc_dir}
scp -r ${_tfp_dir}/.  ${_tfp4inc_dir}/.  

cd $WORKSPACE
make nd_otapackage_inc -j8



