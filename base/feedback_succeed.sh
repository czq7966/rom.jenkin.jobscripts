# 编译反馈成功
WORKSPACE=${WORKSPACE:-.}

cd $WORKSPACE
if [ "${_verifiedfb}" == "yes" ]; then
	gerrit_review ${_tempfile} 1 ${ids2[@]}
fi

# 删除临时文件
if [ -f ${_tempfile} ]; then
	rm ${_tempfile}
fi

