echo "******编译nd3 u-boot******"
# 编译u-boot
WORKSPACE=${WORKSPACE:-.}
UPDATEPATH=${UPDATEPATH:-${WORKSPACE}/RKTools/windows/AndroidTool/AndroidTool_Release_v2.33/rockdev}

cd $WORKSPACE/u-boot
make distclean
make rk3288_defconfig
make -j4
rm $UPDATEPATH/RK3288UbootLoader_V2.19.07.bin
scp $WORKSPACE/u-boot/RK3288UbootLoader_V2.19.07.bin $UPDATEPATH/RK3288UbootLoader_V2.19.07.bin

