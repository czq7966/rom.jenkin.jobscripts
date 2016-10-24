if [ "${_svn_server_pdir_qa}" != "none" ]; then
	echo "******上传至QA的SVN******"
	_svn_server_pdir_qa="${_svn_server_pdir_qa:-https://192.168.160.4:8443/svn/101pad/待测试/ROM/nd3}"
	_svn_server_dir="${_svn_server_pdir_qa}/${_targetfilename}"
	_svn_local_dir="${_output_dir}"
	_svn_message="${_targetfilename}"
	_svn_username=czq761208
	_svn_password=761208
	svn mkdir  ${_svn_server_dir} -m ${_svn_message} --username ${_svn_username} --password ${_svn_password} --parents 2>&1
	svn import ${_svn_local_dir} ${_svn_server_dir} -m ${_svn_message} --username ${_svn_username} --password ${_svn_password}  
fi

