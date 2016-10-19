cd $WORKSPACE
UPDATEPATH=$WORKSPACE/RKTools/windows/AndroidTool/AndroidTool_Release_v2.33/rockdev

_project=libreoffice/core
_branchver=dev
_branchcr=(dev)
_branchcode=dev
_variant=userdebug
_product=nd3
_nettype=wifi
_device=ND3
_sku=CN


source ${JENKINS_HOME}/jobscripts/base_functions_ppt.sh


git fetch
git checkout -B ${_branchver} origin/${_branchcode}

temp_file=temp.txt
> $temp_file
gerrit_query_open ${temp_file} ${_project} ${_branchcr[@]} 


unset ids
unset ids2
for _branchcur in ${_branchcr[@]}  
do
	evalStr="cat $temp_file | jq 'select(.branch == \"${_branchcur}\")' | jq 'select(.number != null)' | jq '.number | tonumber'"
	ids=(`eval $evalStr`)
	idssort=( $(for val in "${ids[@]}"  
	do 
	 echo "$val" 
	done | sort -n) ) 
	gerrit_review $temp_file 0 ${idssort[@]}	
	git_cherry_pick $temp_file $_branchcur ${idssort[@]}
	ids2=(${ids2[@]} ${idssort[@]})
done 

echo "${ids2[@]}"


git_rebase_branch ${_branchcr[@]}


git checkout -B ${_branchver} ${_branchcode}

# 编译Android
cd $WORKSPACE
echo "--with-distro=LibreOfficeAndroid" > ./autogen.input
./autogen.sh
make clean
make

cd $WORKSPACE
gerrit_review $temp_file 1 ${ids2[@]}


rm $temp_file



