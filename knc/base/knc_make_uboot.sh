echo "******编译nd3 u-boot******"
# 编译u-boot
WORKSPACE=${WORKSPACE:-.}
BUILDPATH=${BUILDPATH:-${WORKSPACE}}
UPDATEPATH=${UPDATEPATH:-${BUILDPATH}/RKTools/windows/AndroidTool/AndroidTool_Release_v2.33/rockdev}

cd $BUILDPATH/u-boot
make distclean
make rk3288_defconfig
make -j4
rm $UPDATEPATH/RK3288UbootLoader_V2.19.07.bin
scp $BUILDPATH/u-boot/RK3288UbootLoader_V2.19.07.bin $UPDATEPATH/RK3288UbootLoader_V2.19.07.bin

