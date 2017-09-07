echo "******edurom kernel******"
# 编译kernel
WORKSPACE=${WORKSPACE:-.}
BUILDPATH=${BUILDPATH:-${WORKSPACE}}

cd $BUILDPATH/kernel
make distclean
make rockchip_nd3_defconfig
make rk3288-tb.img -j8
