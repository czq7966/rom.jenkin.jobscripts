cd $WORKSPACE/android4.4

_project=nd2x
_branch=dev
_variant=eng
_product=fiber_a31stm
_nettype=wifi
_device=ND2X
_sku=CN


git fetch
git reset --hard origin/${_branch}
git checkout -B ${_branch} origin/${_branch}


temp_file=temp.txt
ssh gerrit-server gerrit query status:open project:${_project} branch:${_branch}  --format=JSON --patch-sets > $temp_file
ids=`cat $temp_file | jq 'select(.number != null)' | jq '.number | tonumber'`
ids=($ids)

ids2=( $(for val in "${ids[@]}"  
do 
 echo "$val" 
done | sort) ) 

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


source build/envsetup.sh
lunch ${_product}-${_variant}-${_nettype}-${_device}-${_sku}
rm -f ${ANDROID_PRODUCT_OUT}/system/build.prop
extract-bsp
make update-api
make -j8
pack


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
        _REFSPEC_NUM=${_GERRIT_REFSPEC##*/}

        echo $_GERRIT_PROJECT $_GERRIT_REFSPEC $_REFSPEC_NUM
        
	ssh gerrit-server gerrit review ${ids2[$i]},${_REFSPEC_NUM} --message "Build_Successful" --verified 1
done  


rm $temp_file



