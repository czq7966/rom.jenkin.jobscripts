if [ "${_ftp_server_pdir_qa}" != "none" ]; then
	echo "******上传至QA的FTP******"
#	TARGET_NET_TYPE="wifi"
#	_versionname="1.0.0.0"
#	_targetfilename="_targetfilename1"
#	_output_dir="/home2/jenkins/workspace/nd3_wifi_test_compile/RKTools/windows/AndroidTool/AndroidTool_Release_v2.33/rockdev/output"
	_ftp_server_pdir_qa="${_ftp_server_pdir_qa:-192.168.160.4/nd3}"
	_ftp_server_dir="${_ftp_server_pdir_qa}/${TARGET_NET_TYPE}-v${_versionname}/${_targetfilename}"
	_ftp_local_dir="${_output_dir}"
	_ftp_message="${_targetfilename}"
	_ftp_username=101pad
	_ftp_password=101pad
	cd ${_ftp_local_dir}
	find -type f > filelist.txt
	while read i ; do wput $i  ftp://${_ftp_username}:${_ftp_password}@${_ftp_server_dir}/$i ; done < filelist.txt
	rm filelist.txt
fi

