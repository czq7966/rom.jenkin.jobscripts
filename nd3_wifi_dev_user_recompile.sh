cd $WORKSPACE

_project=nd3
_branchver=dev
_branchcr=(dev)
_branchcode=dev
_variant=user
_product=nd3
_nettype=wifi
_device=ND3
_sku=CN

git clean -fd
git fetch
git reset --hard origin/${_branchcode}
git checkout -B ${_branchver} origin/${_branchcode}

temp_file=temp.txt
> $temp_file
unset ids
unset ids2
for _branchcur in ${_branchcr[@]}  
do  
	ssh gerrit-server gerrit query status:open project:${_project} branch:${_branchcur} --format=JSON --patch-sets >> $temp_file
	evalStr="cat $temp_file | jq 'select(.branch == \"${_branchcur}\")' | jq 'select(.number != null)' | jq '.number | tonumber'"
	ids=(`eval $evalStr`)
	idssort=( $(for val in "${ids[@]}"  
	do 
	 echo "$val" 
	done | sort) ) 
	ids2=(${ids2[@]} ${idssort[@]})
done 

echo "${ids2[@]}"

for ((i=0; i<${#ids2[@]}; ++i))  
do  
        id='"'${ids2[$i]}'"'
	evalStr="cat $temp_file | jq 'select(.number == $id)' | jq '{\"project\":.project, \"ref\": .patchSets[.patchSets | length - 1].ref}'"
	_GERRIT_PROJECT=`eval $evalStr | jq .project`
	_GERRIT_REFSPEC=`eval $evalStr | jq .ref`
        _GERRIT_PROJECT=${_GERRIT_PROJECT#\"}
        _GERRIT_PROJECT=${_GERRIT_PROJECT%\"}
	_GERRIT_REFSPEC=${_GERRIT_REFSPEC#\"}
	_GERRIT_REFSPEC=${_GERRIT_REFSPEC%\"}
        echo $_GERRIT_PROJECT $_GERRIT_REFSPEC
        git fetch --tags --progress gerrit-server:${_GERRIT_PROJECT} ${_GERRIT_REFSPEC}
#        git cherry-pick   -Xtheirs FETCH_HEAD
        git cherry-pick  FETCH_HEAD
done  

cd $WORKSPACE/u-boot
make distclean
make rk3288_defconfig
make -j4

cd $WORKSPACE/kernel
make distclean
make rockchip_nd3_defconfig
make rk3288-tb.img -j8

cd $WORKSPACE
source build/envsetup.sh
lunch ${_product}-${_variant}-${_nettype}-${_device}-${_sku}
make clean
make update-api
make -j8
source mkimage.sh



rm $temp_file



