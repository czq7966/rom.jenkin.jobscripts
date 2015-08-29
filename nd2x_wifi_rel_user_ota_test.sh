WORKSPACE=/home2/jenkins/workspace/nd2x_wifi_rel_user_ota
cd $WORKSPACE/android4.4

TARGET_NET_TYPE=wifi
RO_PRODUCT_FIRMWARE_VERSION=1.0.0
RO_PRODUCT_FIRMWARE_PACK_NUMBER=test

_output_dir="$WORKSPACE/lichee"
_targetfilename=ND2X_CN_${TARGET_NET_TYPE}-v${RO_PRODUCT_FIRMWARE_VERSION}.${RO_PRODUCT_FIRMWARE_PACK_NUMBER}

_svn_server_dir="https://192.168.160.4:8443/svn/101pad/待测试/ROM/${TARGET_NET_TYPE}-v${RO_PRODUCT_FIRMWARE_VERSION}.${RO_PRODUCT_FIRMWARE_PACK_NUMBER}/${_targetfilename}"
_svn_local_dir="${_output_dir}"
_svn_message="${_targetfilename}"
_svn_username=czq761208
_svn_password=761208

svn import ${_svn_local_dir} ${_svn_server_dir} -m ${_svn_message} --username ${_svn_username} --password ${_svn_password}









