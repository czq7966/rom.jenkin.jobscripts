echo "******准备代码******"
# 准备代码，会产生一个临时文件 _tempfile=temp.txt，依赖于base_functions.sh脚本及default_params.sh，请先加载该脚本
git clean -fd
git fetch
git reset --hard origin/${_branchcode}
git checkout -B ${_branchver} origin/${_branchcode}
_tempfile=${_tempfile:-temp.txt}
> ${_tempfile}
gerrit_query_open ${_tempfile} ${_project} ${_branchcr[@]} 


unset ids
unset ids2
for _branchcur in ${_branchcr[@]}  
do
	evalStr="cat ${_tempfile} | jq 'select(.branch == \"${_branchcur}\")' | jq 'select(.number != null)' | jq '.number | tonumber'"
	ids=(`eval $evalStr`)
	idssort=( $(for val in "${ids[@]}"  
	do 
	 echo "$val" 
	done | sort -n) ) 
	if [ "${_verifiedfb}" == "yes" ]; then
		gerrit_review ${_tempfile} 0 ${idssort[@]}	
	fi
	git_cherry_pick ${_tempfile} $_branchcur ${idssort[@]}
	ids2=(${ids2[@]} ${idssort[@]})
done 
echo "${ids2[@]}"

git_rebase_branch ${_branchcr[@]}
git checkout -B ${_branchver} ${_branchcode}
for _pick in ${_branchpick[@]}  
do 
	git cherry-pick ${_pick}
done
