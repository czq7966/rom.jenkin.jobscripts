echo "******加载与Gerrit通信的自定义函数******"
#自动从本地库中获取服务器地址
if [ -z "${_GERRIT_SERVER}" ]; then
	_GERRIT_SERVER=`git config --get remote.origin.url`
	_GERRIT_SERVER=${_GERRIT_SERVER%\:*}
fi
echo $_GERRIT_SERVER

#第一个参数：要存储的文件名；第二个参数：project name；第三个参数：分支名
function gerrit_query_open()
{
	local __tempfile=$1
	local __project=$2
	local __branch=
	local __idx=0
	for v in $@
	do
		let __idx=__idx+1
		if [ ${__idx} -gt 2 ]; then
			__branch=$v
			ssh ${_GERRIT_SERVER} gerrit query status:open project:${__project} branch:${__branch} --format=JSON --patch-sets >> ${__tempfile}
		fi	
	done
}

#第一个参数：临时文件名，第二个参数：review的值 0 or 1　后面的参数：CR的number值
function gerrit_review()
{
	local __tempfile=$1
	local __reviewvalue=$2
	local __reviewmessage=("Build_Restart" "Build_Successful")
	local __number=
	local __idx=0
	for v in $@
	do
		let __idx=__idx+1
		if [ ${__idx} -gt 2 ]; then
			__number='"'$v'"'
			__evalStr="cat ${__tempfile} | jq 'select(.number == ${__number})' | jq '{\"project\":.project, \"ref\": .patchSets[.patchSets | length - 1].ref}'"
			__GERRIT_PROJECT=`eval ${__evalStr} | jq .project`
			__GERRIT_REFSPEC=`eval ${__evalStr} | jq .ref`
			if [ -n "${__GERRIT_PROJECT}" ]; then
				__GERRIT_PROJECT=${__GERRIT_PROJECT#\"}
				__GERRIT_PROJECT=${__GERRIT_PROJECT%\"}
				__GERRIT_REFSPEC=${__GERRIT_REFSPEC#\"}
				__GERRIT_REFSPEC=${__GERRIT_REFSPEC%\"}
				__REFSPEC_NUM=${__GERRIT_REFSPEC##*/}
				echo "gerrit_review " ${v} $__GERRIT_PROJECT $__GERRIT_REFSPEC $__REFSPEC_NUM  
				ssh ${_GERRIT_SERVER} gerrit review ${v},${__REFSPEC_NUM} --message ${__reviewmessage[$__reviewvalue]} --verified $__reviewvalue
			fi
		fi		
	done

}


function gerrit_review_1()
{
	local __tempfile=$1
	local __number=
	local __idx=0
	for v in $@
	do
		let __idx=__idx+1
		if [ ${__idx} -gt 1 ]; then
			__number='"'$v'"'
			__evalStr="cat ${__tempfile} | jq 'select(.number == ${__number})' | jq '{\"project\":.project, \"ref\": .patchSets[.patchSets | length - 1].ref}'"
			__GERRIT_PROJECT=`eval ${__evalStr} | jq .project`
			__GERRIT_REFSPEC=`eval ${__evalStr} | jq .ref`
			if [ -n "${__GERRIT_PROJECT}" ]; then
				__GERRIT_PROJECT=${__GERRIT_PROJECT#\"}
				__GERRIT_PROJECT=${__GERRIT_PROJECT%\"}
				__GERRIT_REFSPEC=${__GERRIT_REFSPEC#\"}
				__GERRIT_REFSPEC=${__GERRIT_REFSPEC%\"}
				__REFSPEC_NUM=${__GERRIT_REFSPEC##*/}
				echo $__GERRIT_PROJECT $__GERRIT_REFSPEC $__REFSPEC_NUM  
				ssh ${_GERRIT_SERVER} gerrit review ${ids2[$i]},${_REFSPEC_NUM} --message "Build_Successful" --verified 1
			fi
		fi
	done

}



#第一个参数：临时文件名；第二个参数：分支名；后面的参数：CR的number值
function git_cherry_pick()
{
	local __tempfile=$1
	local __branch=$2
	local __number=
	local __idx=0
	git checkout -B $__branch origin/$__branch
	for v in $@
	do
		let __idx=__idx+1
		if [ ${__idx} -gt 2 ]; then
			__number='"'$v'"'
			__evalStr="cat ${__tempfile} | jq 'select(.number == ${__number})' | jq '{\"project\":.project, \"ref\": .patchSets[.patchSets | length - 1].ref}'"
			__GERRIT_PROJECT=`eval ${__evalStr} | jq .project`
			__GERRIT_REFSPEC=`eval ${__evalStr} | jq .ref`
			if [ -n "${__GERRIT_PROJECT}" ]; then
				__GERRIT_PROJECT=${__GERRIT_PROJECT#\"}
				__GERRIT_PROJECT=${__GERRIT_PROJECT%\"}
				__GERRIT_REFSPEC=${__GERRIT_REFSPEC#\"}
				__GERRIT_REFSPEC=${__GERRIT_REFSPEC%\"}
				__STRATEGY=`eval echo "$"_CHERRY_PICK_STRATEGY_${v}`
				echo "git_cherry_pick " $__GERRIT_PROJECT $__GERRIT_REFSPEC $v "Strategy_${v}:" ${__STRATEGY}
				git fetch --tags --progress ${_GERRIT_SERVER}:${__GERRIT_PROJECT} ${__GERRIT_REFSPEC}
#			        git cherry-pick   -Xtheirs FETCH_HEAD
				git cherry-pick ${__STRATEGY} FETCH_HEAD

			fi
		fi		
	done

}

#传入要合并的分支列表：第N+1分支，合并到第N分支上
function git_rebase_branch()
{
	local __branch1=
	local __branch2=
	local __idx=0
	echo "合并分支：$@"
	for v in $@
	do
		__branch1=$__branch2
		__branch2=$v
		let __idx=__idx+1
		if [ ${__idx} -gt 1 ]; then
			echo "******正在将 $__branch2 分支rebase到 $__branch1 分支******"
			git checkout $__branch2
			git rebase $__branch1	
			git branch -d $__branch1
			git branch $__branch1 $__branch2
			echo "******已同步分支：$__branch2 和 $__branch1 ******"
		fi
	done

}


