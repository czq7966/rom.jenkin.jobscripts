
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
			ssh ppt-server gerrit query status:open project:${__project} branch:${__branch} --format=JSON --patch-sets >> ${__tempfile}
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
				echo $__GERRIT_PROJECT $__GERRIT_REFSPEC $__REFSPEC_NUM  
				ssh ppt-server gerrit review ${v},${__REFSPEC_NUM} --message ${__reviewmessage[$__reviewvalue]} --verified $__reviewvalue
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
				ssh ppt-server gerrit review ${ids2[$i]},${_REFSPEC_NUM} --message "Build_Successful" --verified 1
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
				echo $__GERRIT_PROJECT $__GERRIT_REFSPEC
				git fetch --tags --progress ppt-server:${__GERRIT_PROJECT} ${__GERRIT_REFSPEC}
#			        git cherry-pick   -Xtheirs FETCH_HEAD
				git cherry-pick  FETCH_HEAD

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
	for v in $@
	do
		__branch1=$__branch2
		__branch2=$v
		let __idx=__idx+1
		if [ ${__idx} -gt 1 ]; then
			git checkout $__branch2
			git rebase $__branch1	
		fi
	done

}


