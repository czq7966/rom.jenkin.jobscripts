echo "******编译nd3-6.0 u-boot******"
# 编译u-boot
WORKSPACE=${WORKSPACE:-.}
BUILDPATH=${BUILDPATH:-${WORKSPACE}}
UPDATEPATH=${UPDATEPATH:-${BUILDPATH}/RKTools/windows/AndroidTool/rockdev}
echo $WORKSPACE
cd $BUILDPATH/u-boot
make distclean
make rk3288_defconfig
make -j4
if [ -f $UPDATEPATH/RK3288UbootLoader*.bin ]; then
	rm $UPDATEPATH/RK3288UbootLoader*.bin
fi
scp $BUILDPATH/u-boot/RK3288UbootLoader*.bin $UPDATEPATH/.


