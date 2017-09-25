echo "******编译nd3-6.0 kernel******"
# 编译kernel
WORKSPACE=${WORKSPACE:-.}
BUILDPATH=${BUILDPATH:-${WORKSPACE}}

cd $BUILDPATH/kernel
make distclean
make nd3-rk3288_defconfig
make nd3-6.0-rk3288-tb.img -j8
