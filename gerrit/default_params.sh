_remote_server=${_remote_server:-gerrit81}
_remote_dir=${_remote_dir:-/home/gerrit2/gerrit_site/git}
_remote_cmd="find ${_remote_dir} -name '*.git'"

_local_server=${_local_server:-gerrit75}
_local_server_admin=${_local_server_admin:-gerrit75-admin}
_local_dir=${_local_dir:-/home/nd/gerrit/git}

_local_super_group="Administrators"
_local_project_gropus="owner read push review verified submit"
_local_project_group_description=(项目的所有者 有下载代码的权限 有上传代码的权限 有审核代码的权限 有验证代码的权限 有提交代码入库的权限)
