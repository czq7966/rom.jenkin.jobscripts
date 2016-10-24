if [ "${_svn_server_pdir}" != "none" ]; then
	echo "********上传至部门内SVN********"
	_svn_server_pdir="${_svn_server_pdir:-https://192.168.19.238/svn/101PAD/ROM包/nd3/临时测试包}"
	_svn_server_dir="${_svn_server_pdir}/${_targetfilename}"
	_svn_local_dir="${_output_dir}"
	_svn_message="${_targetfilename}"
	_svn_username=admin
	_svn_password=admin.654321
	svn mkdir  ${_svn_server_dir} -m ${_svn_message} --username ${_svn_username} --password ${_svn_password} --parents 2>&1
	svn import ${_svn_local_dir} ${_svn_server_dir} -m ${_svn_message} --username ${_svn_username} --password ${_svn_password}  
fi

