#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:/root/bin:~/bin
export PATH
# Check if user is root
if [ $UID != 0 ]; then echo "Error: You must be root to run the install script, please use root to install lanmps";exit;fi
START="no"

. lib/common.sh

echo "Select sphinx :
    1 sphinx ${VERS['sphinx']} 
    2 sphinx-for-chinese ${VERS['sphinx-for-chinese']} (default)
    3 sphinx-coreseek ${VERS['sphinx-coreseek']}
    4 no
	"
read -p "Please Input : " SPHINX_SELECT

if [ "$SPHINX_SELECT" == "" ]; then
    SPHINX_SELECT=2
fi
if [ "$SPHINX_SELECT" == "1" ]; then
	SPHINX_ID="sphinx"
elif [ "$SPHINX_SELECT" == "2" ]; then
	SPHINX_ID="sphinx-for-chinese"
elif [ "$SPHINX_SELECT" == "3" ]; then
	SPHINX_ID="sphinx-coreseek"
	if [ "$OS_RL" == "ubuntu" ]; then
		SPHINX_ID=""
		echo " Coreseek cannot be installed on Ubuntu 14.x,13.x,12.x "
	fi
else
    SPHINX_ID=""
fi
echo "Input $SPHINX_SELECT  ,sphinx Name ${SPHINX_ID}"

echo ${VERS['sphinx-for-chinese']}

function sphinx_init()
{
	if [ "$SPHINX_ID" == "sphinx" ]; then
		ProgramDownloadFiles "sphinx" "sphinx-${VERS['sphinx']}-release.tar.gz"
	elif [ "$SPHINX_ID" == "sphinx-for-chinese" ]; then
		ProgramDownloadFiles "sphinx-for-chinese" "sphinx-for-chinese-${VERS['sphinx-for-chinese']}-dev-r4311.tar.gz"
	elif [ "$SPHINX_ID" == "sphinx-coreseek" ]; then
		ProgramDownloadFiles "coreseek" "coreseek-${VERS['sphinx-coreseek']}-beta.tar.gz"
	fi
}
sphinx_init  2>&1 | tee -a "${LOGPATH}/11.Install_Sphinx_sphinx_init.log"

Install_Sphinx  2>&1 | tee -a "${LOGPATH}/11.Install_Sphinx_${SPHINX_ID}.log"