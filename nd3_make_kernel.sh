echo "******编译nd3 kernel******"
# 编译kernel
WORKSPACE=${WORKSPACE:-.}

cd $WORKSPACE/kernel
make distclean
make rockchip_nd3_defconfig
make rk3288-tb.img -j8
