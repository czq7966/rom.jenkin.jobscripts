cd $WORKSPACE
UPDATEPATH=$WORKSPACE/RKTools/windows/AndroidTool/AndroidTool_Release_v2.33/rockdev

_project=nd3
_branchver=dev
_branchcr=(dev)
_branchcode=dev
_variant=userdebug
_product=nd3
_nettype=wifi
_device=ND3
_sku=CN


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
			ssh gerrit-server gerrit query status:open project:${__project} branch:${__branch} --format=JSON --patch-sets >> ${__tempfile}
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
				ssh gerrit-server gerrit review ${v},${__REFSPEC_NUM} --message ${__reviewmessage[$__reviewvalue]} --verified $__reviewvalue
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
				ssh gerrit-server gerrit review ${ids2[$i]},${_REFSPEC_NUM} --message "Build_Successful" --verified 1
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
				git fetch --tags --progress gerrit-server:${__GERRIT_PROJECT} ${__GERRIT_REFSPEC}
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



git clean -fd
git fetch
git reset --hard origin/${_branchcode}
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
#	gerrit_review $temp_file 0 ${idssort[@]}	
	git_cherry_pick $temp_file $_branchcur ${idssort[@]}
	ids2=(${ids2[@]} ${idssort[@]})
done 

echo "${ids2[@]}"

git_rebase_branch ${_branchcr[@]}

git checkout -B ${_branchver} ${_branchcode}

# 编译u-boot
cd $WORKSPACE/u-boot
make distclean
make rk3288_defconfig
make -j4
rm $UPDATEPATH/RK3288UbootLoader_V2.19.07.bin
scp $WORKSPACE/u-boot/RK3288UbootLoader_V2.19.07.bin $UPDATEPATH/RK3288UbootLoader_V2.19.07.bin

# 编译kernel
cd $WORKSPACE/kernel
make distclean
make rockchip_nd3_defconfig
make rk3288-tb.img -j8

# 编译Android
cd $WORKSPACE
source build/envsetup.sh
lunch ${_product}-${_variant}-${_nettype}-${_device}-${_sku}
make clean
make update-api
make -j8
source mkimage.sh ota

# 生成刷机包
cd $UPDATEPATH
source mkupdate.sh

cd $WORKSPACE
_versionname=${RO_PRODUCT_FIRMWARE_VERSION}.${RO_PRODUCT_FIRMWARE_PACK_NUMBER}
_sourcefilename="$UPDATEPATH/update.img"
_targetfilename=${TARGET_USERS_DEVICE}_${TARGET_USERS_SKU}_${TARGET_BUILD_VARIANT}-${CURRENT_GIT_BRANCH}-${TARGET_NET_TYPE}-${CURRENT_GIT_BRANCH_SHA}_`date +%Y%m%d-%H%M`_v${_versionname}
_targetfileimg=${_targetfilename}.img


# 复制到共享服务器
_share_ota_dir=" /home/192.168.51.38/pub/nd3/DEV测试包"
mkdir -p ${_share_ota_dir}
scp -r ${_sourcefilename}  ${_share_ota_dir}/${_targetfileimg}


#gerrit_review $temp_file 1 ${ids2[@]}


rm $temp_file



