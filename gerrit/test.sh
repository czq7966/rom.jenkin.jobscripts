JOBSCRIPTSPATH=${JENKINS_HOME}/jobscripts

# 加载与Gerrit通信的自定义函数
source ${JOBSCRIPTSPATH}/gerrit/default_params.sh
source ${JOBSCRIPTSPATH}/gerrit/base_functions.sh

gerrit_batch_create_group_by_project "test"
#gerrit_create_group "test1" "test"
#gerrrit_delete_group ""
#__exists=$(gerrrit_exist_group "Administratosrs") 

#if [ $(gerrrit_delete_group "Administrators")  == "1" ]; then
#	echo 'bbbbbbbbb'
#fi

exit




__remote_project=${_remote_dir}/test.git
__local_project=${__remote_project/${_remote_dir}/${_local_dir}}

mirror_project ${__remote_project} ${__local_project}
gerrit_flush_caches

#result=$(get_projects_name)
#for v in $result
#do
#	echo $v
#	__remote_project=$v
#	__local_project=${v/${_remote_dir}/${_local_dir}}
#	mirror_project ${__remote_project} ${__local_project}

#	echo $i
#	exit
#done

