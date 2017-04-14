
#_remote_git_dir=${_remote_dir:-/home/gerrit2/gerrit_site/git}
_old_gerrit_server=${_old_gerrit_server:-sdpgerrit-admin}
_remote_server=${_remote_server:-sdpgitlab}
#_remote_git_dir=${_remote_dir:-/etc/gerrit}


_local_server=${_local_server:-gerrit179}
_local_server_admin=${_local_server_admin:-gerrit179-admin}
_local_gerrit_site=${_local_gerrit_site:-/home/gerrit/site}
#_local_server=${_local_server:-gerrit75}
#_local_server_admin=${_local_server_admin:-gerrit75-admin}
#_local_gerrit_site=${_local_gerrit_site:-/home/nd/gerrit}
_local_git_dir=${_local_git_dir:-${_local_gerrit_site}/git}
_local_bak_dir=${_local_bak_dir:-${_local_gerrit_site}/bak}


_local_admin_group="Administrators"
_local_non_interactive_group="Non-Interactive Users"
_local_predefined_group=("${_local_admin_group}" "${_local_non_interactive_group}")

_local_group_subfix_owner="_owner"
_local_group_subfix_read="_read"
_local_group_subfix_push="_push"
_local_group_subfix_review="_review"
_local_group_subfix_verified="_verified"
_local_group_subfix_submit="_submit"
_local_project_gropus_subfix="${_local_group_subfix_owner} ${_local_group_subfix_read} ${_local_group_subfix_push} ${_local_group_subfix_review} ${_local_group_subfix_verified} ${_local_group_subfix_submit}"
_local_project_group_description=("项目的所有者" "有下载代码的权限" "有上传代码的权限" "有审核代码的权限" "有验证代码的权限" "有提交代码入库的权限")
