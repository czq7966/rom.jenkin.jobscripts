function get_projects_name()
{
	__projects=`ssh ${_remote_server} "${_remote_cmd}"`
	echo $__projects
}


function mirror_project()
{
	__remote_project=$1
	__local_project=$2
	__local_parent=${__targetproject%/*}
	echo  ${__remote_project} ${__local_project}
	if [ ! -d ${__local_project} ]; then
		echo ${__local_project}
		__cmd="git clone --mirror ${_remote_server}:${__remote_project} ${__local_project}"
		echo "正在克隆仓库：${__cmd}"
		ssh ${_local_server} "${__cmd}"
		echo "克隆仓库完成：ssh ${_local_server} ${__cmd}"
	fi

}


function gerrit_execute()
{
	__cmd=$1
	ssh ${_local_server_admin} \"${__cmd}\"
	__cmd="ssh ${_local_server_admin} ${__cmd}"
	echo "正在执行命令：${__cmd}"
	__return=`eval ${__cmd}`
	echo "执行命令完成：${__cmd}"
	echo $__return
}


function gerrit_flush_caches()
{
	__cmd="gerrit flush-caches  --all"
	__cmd="ssh ${_local_server_admin} \"${__cmd}\""
	echo "正在刷新缓存：${__cmd}"
	eval ${__cmd}
	echo "刷新缓存完成：${__cmd}"
}

# 判断组是否存在 $1=组名
function gerrrit_exist_group()
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
	__owner=${__owner:-"Administrators"}
	__description=${__description:-"${__name}"}

	if [ "${__name}" != "" ]; then
		ssh ${_local_server_admin} "gerrit create-group --owner \"${__owner}\" --description \"${__description}\" \"${__name}\""
	fi
	__result=$(gerrrit_exist_group $__name)
	echo $__result
}

# 删除组 $1=组名
function gerrrit_delete_group()
{
	__name=$1
	if [ "${__name}" == "Administrators" -o "${__name}" == "Non-Interactive Users" ]; then
		echo 0
	else
		__result=`ssh ${_local_server_admin} "gerrit gsql --format JSON  -c 'delete from account_group_names where name=\"${__name}\"'"`
		__result=`ssh ${_local_server_admin} "gerrit gsql --format JSON  -c 'delete from account_groups where name=\"${__name}\"'"`
		__result=$(gerrrit_exist_group $__name)
		if [ "$__result" == "1" ]; then
			echo 0
		else
			echo 1
		fi
	fi
}


# 根据项目批量创建6个组 $1＝组名 $2=所有者 $3=描述
function gerrit_batch_create_group_by_project()
{
	__name=$1
	__groups=$_local_project_gropus
	__group=	
	__group_owner=	
	__group_desc=
	__result=0
	__i=0
	if [ "${__name}" != "" ]; then
		for v in $__groups
		do			
			__group=${__name}_$v
			__group_owner=${__group_owner:-${_local_super_group}}
			__group_desc=${_local_project_group_description[$__i]}"（$__name 项目）"
			__result=$(gerrit_create_group "$__group" "$__group_owner" "$__group_desc")
			if [ "$__i" == "0" ]; then
				__group_owner=$__group
			fi
			__i=$__i+1
		done
	fi 
	echo $__result
}







