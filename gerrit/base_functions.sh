

########################################## 系统相关 ########################################

# 刷新缓存
function gerrit_flush_caches()
{
	__name=${1:---all}
	echo $__name
	__result=`ssh ${_local_server_admin} "gerrit flush-caches ${__name}"`
	echo $__result
}

# 刷新索引备份
function gerrit_backup_index()
{
	__bakindex=bak/index_`date "+%Y%m%d%H%M%S"`
	ssh ${_local_server} "cd ${_local_gerrit_site} ; mkdir -p bak; cp -r index $__bakindex"
	echo "已备份索引至：$__bakindex"
}


# 刷新索引并重启
function gerrit_flush_reindex()
{
	if [ "$1" == "yes" ]; then
		ssh ${_local_server} ". ${_local_gerrit_site}/bin/gerrit.sh stop"
		gerrit_backup_index
		ssh ${_local_server} "cd ${_local_gerrit_site} ; java -jar bin/gerrit.war reindex"
		ssh ${_local_server} ". ${_local_gerrit_site}/bin/gerrit.sh start"
	fi
}

# 激活帐号索引
function gerrit_index_activate_accounts()
{
	if [ "$1" == "yes" ]; then
		gerrit_backup_index
		ssh ${_local_server_admin} "gerrit index activate accounts"
	fi
}


# 激活changes索引
function gerrit_index_activate_changes()
{
	if [ "$1" == "yes" ]; then
		gerrit_backup_index
		ssh ${_local_server_admin} "gerrit index activate changes"
	fi
}

# 在线启动帐号索引
function gerrit_index_start_accounts()
{
	if [ "$1" == "yes" ]; then
		gerrit_backup_index
		ssh ${_local_server_admin} "gerrit index start accounts --force"
	fi
}


# 在线启动changes索引
function gerrit_index_start_changes()
{
	if [ "$1" == "yes" ]; then
		gerrit_backup_index
		ssh ${_local_server_admin} "gerrit index start changes --force"
	fi
}



# 刷新重启
function gerrit_restart()
{
	if [ "$1" == "yes" ]; then
		ssh ${_local_server} ". ${_local_gerrit_site}/bin/gerrit.sh stop"
		ssh ${_local_server} ". ${_local_gerrit_site}/bin/gerrit.sh start"
	fi
}

# 系统查看连接
function gerrit_show_connections()
{
	ssh ${_local_server_admin} "gerrit show-connections"
}

# 系统关闭连接
function gerrit_close_connections()
{
	__session_id=$1
	__wait=$2
	if [ "$__session_id" != "" ]; then
		ssh ${_local_server_admin} "gerrit close-connections $__session_id $__wait"
	fi
}


# 系统_同步_重启
function gerrit_replication_reload()
{
	if [ "$1" == "yes" ]; then
		ssh ${_local_server_admin} "gerrit plugin reload replication"
	fi
}

# 系统_同步_开始_手工
function gerrit_replication_start()
{
	__params=$1
	ssh ${_local_server_admin} "replication start $__params"
}

########################################## 项目相关 ########################################

# 判断项目是否存在 $1=项目名
function gerrit_exist_project()
{
	__name=${1%.git}
	__dir="${_local_git_dir}/${__name}.git/objects"
	__result=`ssh ${_local_server} test -d "${__dir}" || echo 0`
	if [ "$__result" == "0" ]; then
		echo 0
	else
		echo 1
	fi
}

# 判断远程项目是否存在 $1=项目名
function gerrit_remote_exist_project()
{
	__name=${1%.git}.git
	__fatal="fatal:"
	__result=`ssh ${_local_server} git ls-remote ${_remote_server}:${__name} 2>&1`
	__result=$(echo $__result | grep "${__fatal}")
	if [ "$__result" == "" ]; then
		echo 1
	else
		echo 0
	fi

#	__name=${1%.git}
#	__dir="${_remote_git_dir}/${__name}.git/objects"
#	__result=`ssh ${_remote_server} test -d "${__dir}" || echo 0`
#	if [ "$__result" == "0" ]; then
#		echo 0
#	else
#		__=$(gerrit_flush_caches)
#		echo 1
#	fi
}

# 创建项目 $1=项目名
function gerrit_create_project()
{
	__name=${1%.git}
	__result=$(gerrit_exist_project ${__name})
	if [ "${__result}" == "1" ]; then
		echo 0 "项目已存在：${__name}"
	else
		__result=`ssh ${_local_server_admin} "gerrit create-project \"${__name}\""`
		__result=$(gerrit_exist_project ${__name})
		__=$(gerrit_flush_caches)
		echo $__result
	fi
}

# 移除项目 $1=项目名
function gerrit_move_project()
{
	__name=${1%.git}
	__result=$(gerrit_exist_project ${__name})
	if [ "${__result}" == "0" ]; then
		echo 1
	else
		__dir=${_local_git_dir}/${__name}.git
		__todir=${_local_bak_dir}/${__name}.git`date "+%Y%m%d%H%M%S"`
		__ptodir=${__todir%/*}
		__result=`ssh ${_local_server} " mkdir -p $__ptodir; cp \"${__dir}\" \"${__todir}\""`
		__result=`ssh ${_local_server_admin} " delete-project delete --yes-really-delete --force ${__name} "`
		__result=$(gerrit_exist_project ${__name})
		__=$(gerrit_flush_caches)
		if [ "${__result}" == "0" ]; then
			echo 1
		else
			echo 0
		fi
	fi
}


# 从远程服上镜像项目 $1=项目名
#function gerrit_mirror_project_from_remote()
#{
#	__name=${1%.git}
#	__result=($(gerrit_exist_project ${__name}))	
#	if [ "${__result}" == "1" ]; then
#		echo 0 "本地项目已存在：${__name}"
#	else
#		__result=($(gerrit_remote_exist_project ${__name}))	
#		if [ "${__result}" == "0" ]; then
#			echo 0 "远程项目不存在：${__name}"
#		else
#			__remote_project=${_remote_git_dir}/${__name}.git
#			__local_project=${__remote_project/${_remote_git_dir}/${_local_git_dir}}
#			__msg=`ssh ${_local_server} git clone --mirror ${_remote_server}:${__remote_project} ${__local_project}`
#			__result=($(gerrit_exist_project ${__name}))
#			__=$(gerrit_flush_caches)
#			echo "$__result" "$__msg"
#		fi		
#	fi
#}

function gerrit_mirror_project_from_remote()
{
	__name=${1%.git}
	__result=($(gerrit_exist_project ${__name}))	
	if [ "${__result}" == "1" ]; then
		echo 0 "本地项目已存在：${__name}"
	else
			__remote_project=${__name}.git
			__local_project=${_local_git_dir}/${__name}.git
			__result=$(gerrit_remote_exist_project "${__name}")
			if [ "${__result}" == "0" ]; then
				echo 0 "远程项目不存在：${__name}"				
			else
				__msg=`ssh ${_local_server_admin} "gerrit create-project \"${__name}.git\""`
				__msg=`ssh ${_local_server} "cd \"${__local_project}\"; git fetch ${_remote_server}:${__remote_project} +refs/heads/*:refs/heads/*"`
				__result=($(gerrit_exist_project ${__name}))
				__=$(gerrit_flush_caches)
				echo "$__result" "$__msg"
			fi
	fi
}

# 从远程服上更新项目 $1=项目名
function gerrit_update_project_from_remote()
{
	__name=${1%.git}
	__result=($(gerrit_exist_project ${__name}))	
	if [ "${__result}" != "1" ]; then
		echo 0 "本地项目不存在：${__name}"
	else
			__remote_project=${__name}.git
			__local_project=${_local_git_dir}/${__name}.git
			ssh ${_local_server} "cd ${__local_project} ; git fetch ${_remote_server}:${__remote_project}  +refs/heads/*:refs/heads/* +refs/tags/*:refs/tags/*"
			__=$(gerrit_flush_caches)
	fi
}

# 从远程服上镜像项目并初始化权限
function gerrit_mirror_project_from_remote_and_init_access()
{
	__name=${1%.git}
	__result=($(gerrit_mirror_project_from_remote "$__name"))
	if [ "$__result" == "1" ]; then
		__result=($(gerrit_batch_create_group_by_project "$__name"))
		if [ "$__result" == "1" ]; then
			__=($(gerrit_batch_include_group_by_project "$__name"))
		fi
		if [ "$__result" == "1" ]; then
			__result=($(gerrit_init_project_access "$__name"))
		fi
	fi
	echo "${__result[*]}"
}

# 创建项目并初始化权限
function gerrit_create_project_and_init_access()
{
	__name=${1%.git}
	__result=($(gerrit_create_project "$__name"))
	if [ "$__result" == "1" ]; then
		__result=($(gerrit_batch_create_group_by_project "$__name"))
		if [ "$__result" == "1" ]; then
			__=($(gerrit_batch_include_group_by_project "$__name"))
		fi
		if [ "$__result" == "1" ]; then
			__result=($(gerrit_init_project_access "$__name"))
		fi
	fi
	echo "${__result[*]}"
}


# 初始化项目权限 $1=项目名
function gerrit_init_project_access()
{
	__name=${1%.git}
	__tempdir=`pwd`/tmp
	rm -rf $__tempdir
	mkdir -p $__tempdir
	cd $__tempdir
	git init
	git fetch ${_local_server_admin}:$__name refs/meta/config
	git checkout -B config FETCH_HEAD
	local_init_project_access "$__name"
	git add .
	git commit -m "初始化权限"
	git push ${_local_server_admin}:$__name HEAD:refs/meta/config
	__=$(gerrit_flush_caches)
	echo 1
}
# 生成groups和project.config权限配置文件 $1=项目名
function local_init_project_access()
{
	__name=${1%.git}
	__groups_file="groups"
	__config_file="project.config"

	__group_owner=${__name}${_local_group_subfix_owner}
	__group_read=${__name}${_local_group_subfix_read}
	__group_push=${__name}${_local_group_subfix_push}
	__group_review=${__name}${_local_group_subfix_review}
	__group_verified=${__name}${_local_group_subfix_verified}
	__group_submit=${__name}${_local_group_subfix_submit}

	__group_owner_uuid=$(gerrit_get_group_uuid "$__group_owner")
	__group_read_uuid=$(gerrit_get_group_uuid "$__group_read")
	__group_push_uuid=$(gerrit_get_group_uuid "$__group_push")
	__group_review_uuid=$(gerrit_get_group_uuid "$__group_review")
	__group_verified_uuid=$(gerrit_get_group_uuid "$__group_verified")
	__group_submit_uuid=$(gerrit_get_group_uuid "$__group_submit")

	 __group_owner_line="$__group_owner_uuid	$__group_owner"
	   __group_read_line="$__group_read_uuid	$__group_read"
	   __group_push_line="$__group_push_uuid	$__group_push"
	__group_review_line="$__group_review_uuid	$__group_review"
	__group_verified_line="$__group_verified_uuid	$__group_verified"
	__group_submit_line="$__group_submit_uuid	$__group_submit"

	echo "# UUID                                  	Group Name" 	>  $__groups_file
	echo "#"                      					>> $__groups_file
	echo "$__group_owner_line"    					>> $__groups_file
	echo "$__group_read_line"     					>> $__groups_file
	echo "$__group_push_line"     					>> $__groups_file
	echo "$__group_review_line"   					>> $__groups_file
	echo "$__group_verified_line" 					>> $__groups_file
	echo "$__group_submit_line"   					>> $__groups_file

	


	echo	"[access]"							>  $__config_file
	echo	"	inheritFrom = All-Projects"				>> $__config_file
	echo	"[access \"refs/*\"]"						>> $__config_file
	echo	"	owner = group $__group_owner"				>> $__config_file
	echo	"	read = group $__group_read"				>> $__config_file
	echo	"[access \"refs/for/refs/*\"]"					>> $__config_file
	echo	"	push = group $__group_push"				>> $__config_file
	echo	"[access \"refs/heads/*\"]"					>> $__config_file	
	echo	"	label-Code-Review = -2..+2 group $__group_review"	>> $__config_file
	echo	"	label-Sonar-Verified = -1..+1 group $__group_review"	>> $__config_file
	echo	"	label-Verified = -1..+1 group $__group_verified"	>> $__config_file
	echo	"	submit = group $__group_submit"				>> $__config_file
	echo	"[access \"refs/meta/config\"]"					>> $__config_file
	echo	"	read = group $__group_read"				>> $__config_file
	echo	"[submit]"							>> $__config_file
	echo	"	action = cherry pick"					>> $__config_file

}



########################################## 账号相关 ########################################
# 判断帐号是否存在
function gerrit_exist_account()
{
	__name=$1
	__result=`ssh ${_local_server_admin} "gerrit gsql --format JSON  -c 'select * from account_external_ids where external_id like  \"%:${__name}\"'"`
	__result=`echo $__result | jq 'select(.type == "query-stats")' | jq '.rowCount | tonumber'` 
	echo $__result
}

# 根据帐号获取帐号ID
function gerrit_get_account_id()
{
	__name=$1
	__result=$(gerrit_exist_account "${__name}")
	if [ "$__result" != "0" ]; then
		__result=`ssh ${_local_server_admin} "gerrit gsql --format JSON  -c 'select * from account_external_ids where external_id like  \"username:${__name}\"'"`
		__result=`echo $__result | jq 'select(.type == "row")' | jq '.columns.account_id | tonumber'` 
	fi
	echo $__result
}


# 创建内部帐号
function gerrit_create_account()
{
	__name=$1
	__full_name=${2}
	if [ "${__full_name}" != "" ]; then
		__full_name=" --full-name \"${__full_name}\""
	fi
	__result=$(gerrit_exist_account "$__name")
	if [ "$__result" == "0" ]; then
#		ssh ${_local_server_admin} "gerrit create-account --email  \"${__name}@nd.com\" --group \"Administrators\" \"${__name}\""
		ssh ${_local_server_admin} "gerrit create-account ${__full_name} \"${__name}\""
		__result=$(gerrit_exist_account "$__name")
	fi	
	echo $__result
}

# 注册外部帐号
function gerrit_register_account()
{
	__name=$1
	__full_name="$2"
	__result=$(gerrit_create_account "$__name" "$__full_name")
	if [ "$__result" == "1" ]; then
		__account_id=$(gerrit_get_account_id "$__name")
		__external_id="gerrit:$__name"
		__result=`ssh ${_local_server_admin} "gerrit gsql --format JSON  -c 'insert into account_external_ids(account_id, external_id) values(${__account_id} , \"${__external_id}\")'"`
	fi
	__result=$(gerrit_exist_account "$__name")
	echo $__result
}

# 删除帐号
function gerrit_delete_account()
{
	__name=$1
	__id=$(gerrit_get_account_id "${__name}")
	if [ "${__id}" == "0" ]; then
		echo 0 "帐号不存在"
	else
		__result=`ssh ${_local_server_admin} "gerrit gsql --format JSON  -c 'delete from accounts where account_id = ${__id}'"`
		__result=`ssh ${_local_server_admin} "gerrit gsql --format JSON  -c 'delete from account_id where s = ${__id}'"`
		__result=`ssh ${_local_server_admin} "gerrit gsql --format JSON  -c 'delete from account_group_members where account_id = ${__id}'"`
		__result=`ssh ${_local_server_admin} "gerrit gsql --format JSON  -c 'delete from account_group_members_audit where account_id = ${__id}'"`
		__result=`ssh ${_local_server_admin} "gerrit gsql --format JSON  -c 'delete from account_external_ids where account_id = ${__id}'"`
		__result=$(gerrit_exist_account "${__name}")
		if [ "${__result}" == "0" ]; then
			echo 1
		else
			echo 0
		fi
	fi

}

# 设置帐号邮箱
function gerrit_set_account_email()
{
	__name=$1
	__email=$2
	if [ "$__name" != "" -a "$__email" != "" ]; then
		echo $__name $__email
		ssh ${_local_server_admin} "gerrit set-account --add-email \"$__email\" $__name"
		ssh ${_local_server_admin} "gerrit set-account --preferred-email \"$__email\" $__name"
	fi
}

# 设置帐号http密码
function gerrit_set_account_http_password()
{
	__name=$1
	__passwd=$2
	if [ "$__name" != "" -a "$__passwd" != "" ]; then
		echo $__name $__passwd
		ssh ${_local_server_admin} "gerrit set-account --http-password \"$__passwd\" $__name"
	fi
}

# 设置帐号Key
function gerrit_set_account_key()
{
	__name=$1
	__key=$2
	if [ "$__name" != "" -a "$__key" != "" ]; then
		echo $__name $__key
		ssh ${_local_server_admin} "gerrit set-account --delete-ssh-key ALL $__name"
		ssh ${_local_server_admin} "gerrit set-account --add-ssh-key \"$__key\" $__name"
	fi
}

# 设置帐号全名full_name
function gerrit_set_account_full_name()
{
	__name=$1
	__full_name=$2
	if [ "$__name" != "" -a "$__full_name" != "" ]; then
		echo $__name $__full_name
		ssh ${_local_server_admin} "gerrit set-account --full-name \"$__full_name\" $__name"
	fi
}


# 设置帐号邮箱(从旧Gerrit平台获取Email)
function gerrit_set_account_email_from_old()
{
	__name=$1
	__email=$(gerrit_get_old_account_email "$__name")
	gerrit_set_account_email "$__name" "$__email"
}


# 设置帐号Key(从旧Gerrit平台获取Key)
function gerrit_set_account_key_from_old()
{
	__name=$1
	__key=$(gerrit_get_old_account_key "$__name")
	gerrit_set_account_key "$__name" "$__key"
}



# 从旧Gerrit平台获取帐号id
function gerrit_get_old_account_id()
{
	__name=$1
	__id=
	__result=`ssh ${_old_gerrit_server} "gerrit gsql --format JSON  -c 'select a.* from accounts as a, account_external_ids b  where a.account_id = b.account_id and b.external_id = \"gerrit:${__name}\"'"`
	__exist=`echo $__result | jq 'select(.type == "query-stats")' | jq '.rowCount | tonumber'` 
	if [ "$__exist" == "1" ]; then
		__id=`echo $__result | jq 'select(.type == "row")' | jq '.columns.account_id | tonumber'` 
	fi

	echo "$__id"
}

# 从旧Gerrit平台获取Email
function gerrit_get_old_account_email()
{
	__name=$1
	__email=
	__result=`ssh ${_old_gerrit_server} "gerrit gsql --format JSON  -c 'select a.* from accounts as a, account_external_ids b  where a.account_id = b.account_id and b.external_id = \"gerrit:${__name}\"'"`
	__exist=`echo $__result | jq 'select(.type == "query-stats")' | jq '.rowCount | tonumber'` 
	if [ "$__exist" == "1" ]; then
		__email=`echo $__result | jq 'select(.type == "row")' | jq '.columns.preferred_email'` 
		__email=${__email#*\"}
		__email=${__email%\"*}		
	fi

	echo "$__email"
}

# 从旧Gerrit平台获取公钥
function gerrit_get_old_account_key()
{
	__name=$1
	__id=$(gerrit_get_old_account_id "$__name")
	if [ "$__id" != "" ]; then
		__All_Users_dir="$JENKINS_HOME/All-Users"
		__keyfile=$__All_Users_dir/$__id
	
		if [ -f "$__keyfile" ]; then
			__keys="`cat $__keyfile`"
			__keys=${__keys//"# DELETED"/}
			echo "$__keys"
		fi	
	fi
}


# 导入帐号
function gerrit_import_accounts()
{
	__file=$1
	__accounts=""
	if [ -f "$__file" ]; then
		
		while read line
		do
			__account=($line "")
			__name=${__account[0]}
			__full_name=${__account[1]}
			__accounts="${__accounts} $__name;$__full_name"
		done < $__file
		echo $__accounts		
		__i=0
		for v in  $__accounts
		do
			__account=(${v/;/ } "")
			__name=${__account[0]}
			__full_name=${__account[1]}	
			__result=$(gerrit_register_account "$__name" "$__full_name")
			__i=$[__i+1]
			echo "$__i" "$__name" "$__full_name" "$__result"
#			gerrit_set_account_email_from_old "$__name"
#			gerrit_set_account_key_from_old "$__name"

		done
		gerrit_flush_reindex
	fi
	
}

# 导入帐号
function gerrit_import_email_key_from_old()
{
	__file=$1
	__accounts=""
	if [ -f "$__file" ]; then
		
		while read line
		do
			__account=($line "")
			__name=${__account[0]}
			__full_name=${__account[1]}
			__accounts="${__accounts} $__name;$__full_name"
		done < $__file
		echo $__accounts		
		__i=0
		for v in  $__accounts
		do
			__account=(${v/;/ } "")
			__name=${__account[0]}
			__full_name=${__account[1]}	
			__i=$[__i+1]
			echo "$__i" "$__name" "$__full_name" "$__result"
			gerrit_set_account_email_from_old "$__name"
			gerrit_set_account_key_from_old "$__name"

		done
	fi
}


########################################## 组相关 ########################################
# 判断组是否存在 $1=组名
function gerrit_exist_group()
{
	__name=$1
	__result=`ssh ${_local_server_admin} "gerrit gsql --format  JSON  -c 'select * from account_groups where name=\"${__name}\"'" `
	__result=`echo $__result | jq 'select(.type == "query-stats")' | jq '.rowCount | tonumber'` 
	echo $__result
}


# 创建组 $1＝组名 $2=所有者 $3=描述
function gerrit_create_group()
{
	__name=$1
	__owner=$2
	__description=$3
	
#	__owner=${__owner:-"--owner Administrators"}
	__description=${__description:-"${__name}"}


	if [ "$__owner" != "" ]; then
		__owner=" --owner \"${__owner}\""
	fi

	if [ "${__name}" != "" ]; then
		ssh ${_local_server_admin} "gerrit create-group ${__owner} --description \"${__description}\" \"${__name}\""
	fi
	__result=$(gerrit_exist_group $__name)
	echo $__result
}

# 设置组的用户成员
function gerrit_set_members_user()
{
	__name=$1
	__user=$2

	if [ "${__name}" != "" -a "${__user}" != "" ]; then
		ssh ${_local_server_admin} "gerrit set-members --add \"${__user}\" \"${__name}\""
		echo 1
	else
		echo 0
	fi

}


# 设置组的组成员
function gerrit_set_members_group()
{
	__name=$1
	__group=$2

	if [ "${__name}" != "" -a "${__group}" != "" ]; then
		ssh ${_local_server_admin} "gerrit set-members --include \"${__group}\" \"${__name}\""
		echo 1
	else
		echo 0
	fi

}

# 获取组的UUID
function gerrit_get_group_uuid()
{
	__name=$1
	__uuid=
	__exist=$(gerrit_exist_group "$__name")
	if [ "$__exist" == "1" ]; then
		__result=`ssh ${_local_server_admin} "gerrit gsql --format  JSON  -c 'select * from account_groups where name=\"${__name}\"'" `
		__uuid=`echo $__result | jq 'select(.type == "row")' | jq '.columns.group_uuid'` 
		__uuid=${__uuid#*\"}
		__uuid=${__uuid%\"*}
	fi
	echo "$__uuid"
}


# 删除组 $1=组名
function gerrit_delete_group()
{
	__name=$1
	if [ "${__name}" == "${_local_admin_group}" -o "${__name}" == "${_local_non_interactive_group}" ]; then
		echo 0
	else
		__result=`ssh ${_local_server_admin} "gerrit gsql --format JSON  -c 'delete from account_group_names where name=\"${__name}\"'"`
		__result=`ssh ${_local_server_admin} "gerrit gsql --format JSON  -c 'delete from account_groups where name=\"${__name}\"'"`
		__result=($(gerrit_exist_group $__name))
		__=$(gerrit_flush_caches)
		if [ "$__result" == "1" ]; then
			echo 0
		else
			echo 1
		fi
	fi
}


# 根据项目批量创建6个组 $1＝项目名
function gerrit_batch_create_group_by_project()
{
	__name=${1%.git}
	__groups=$_local_project_gropus_subfix
	__group=	
	__group_owner=
	__group_desc=
	__result=0
	__i=0
	if [ "${__name}" != "" ]; then
		for v in $__groups
		do			
			__group=${__name}$v
			__group_desc=${_local_project_group_description[$__i]}"（$__name 项目）"
			__result=$(gerrit_create_group "$__group" "$__group_owner" "$__group_desc")
			__group_owner=${__name}${_local_group_subfix_owner}	
			__i=${__i}+1
		done

	fi 
	__=$(gerrit_flush_caches)
	echo $__result
}


# 根据项目将其它５组加入read组 $1＝项目名
function gerrit_batch_include_group_by_project()
{
	__name=${1%.git}
	__group_read=${__name}${_local_group_subfix_read}
	__groups=$_local_project_gropus_subfix
	__group=	
	__result=0
	__i=0
	if [ "${__name}" != "" ]; then
		for v in $__groups
		do			
			if [ "${v}" != "${_local_group_subfix_read}" ]; then 
				__group=${__name}$v
				__result=$(gerrit_exist_group "$__group")
				if [ "${__result}" == "1" ]; then 
					__result=$(gerrit_set_members_group "$__group_read" "$__group")
				fi
			fi
		done

	fi 
	echo $__result
}





# 根据项目批量删除6个组 $1＝项目名
function gerrit_batch_delete_group_by_project()
{
	__name=${1%.git}
	__groups=$_local_project_gropus_subfix
	__group=	
	__result=0
	if [ "${__name}" != "" ]; then
		for v in $__groups
		do			
			__group=${__name}$v
			__result=($(gerrit_delete_group "$__group"))
		done
	fi 
	__=$(gerrit_flush_caches)
	echo $__result
}


function extract_All_Users_authorized_keys()
{
	__All_Users_dir="$JENKINS_HOME/All-Users"
	cd ${__All_Users_dir}/.git/refs/users
	__users=`find -type f`
	for v in $__users
	do
		v=${v#*.}
		__refs="refs/users"$v
		__user=${v##*/}

		echo $__refs $__user
		cd ${__All_Users_dir}
		git checkout -B user $__refs
		if [ -f "authorized_keys" ]; then
			cp authorized_keys $__user
		fi
	done
}

########################################## Change 相关 ########################################

function gerrit_delete_sonar_patch_comments()
{
	__change_id=$1
	__patch_set_id=$2
	__status="P"
	if [ "${__change_id}" == "" ]; then
		echo 0 "change_id 不能为空"
	elif [ "${__patch_set_id}" == "" ]; then
		echo 0 "patch_set_id 不能为空"
	else
		__result=`ssh ${_local_server_admin} "gerrit gsql --format JSON  -c 'delete from  patch_comments where status = \"${__status}\" and change_id = ${__change_id} and patch_set_id = ${__patch_set_id}'"`
		echo 1 "${__result}"
	fi
	
}



