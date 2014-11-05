function wget_down {
    if [ $SOFT_DOWN == 1 ]; then
        echo "start down..."
        for i in $*;
		do
			echo "wget -c $i";
            [ $(wget -c $i) ] && exit
        done
    fi
}

function err_exit {
    echo 
    echo "----Install Error: $1 -----------"
	echo $1
    echo "----Install Error over: -----------"
    echo
    exit
}

function error {
    echo "ERROR: $1"
}

function file_cp {
    if [ -f $2 ]; then 
		echo "$2 [fount]"
		echo "mv $2 ${2}_"$(date +%Y%m%d%H)
		mv $2 ${2}_$(date +%Y%m%d%H);
	fi
    cd $IN_PWD/conf
	echo "$IN_PWD/conf/$1"
    [ -f $1 ] && cp -f $1 $2
}

function file_cpv {
    cd $IN_PWD/conf
    [ -f $1 ] && cp -f $1 $2
}

function file_rm {
    if [ -f $1 ]; then
		echo "rm -f $1"
		rm -f $1
	fi
}

function file_bk {
	if [ -f $1 ]; then 
		echo "$1 [fount]"
		echo "mv $1 ${1}_"$(date +%Y%m%d%H)
		mv $1 ${1}_$(date +%Y%m%d%H);
	fi
}

function ProgramIsInstalled()
{
	echo "===check $1"
	local t_name=$1
	if [ $3 ]; then
		t_name=$3
	fi
	LIBS[$t_name]="Not"
	if type -p $1 >/dev/null; then
		echo "Installed"
		LIBS[$t_name]="Installed"
	else
		echo "Not Installed"
		LIBS[$t_name]=$2
		cd $IN_DOWN
		if [ -s $2 ]; then
			echo "$IN_DOWN/$2 [found]"
		else
			echo "Error: $IN_DOWN/$2 not found!!!download now......"
			wget_down ${DUS[$t_name]}
		fi
	fi
	#return ${LIBS[$t_name]}
}

function SoInstallationLocation()
{
	echo "===SoInstallationLocation $1.so"
	local t_name=$1
	if [ $3 ]; then
		t_name=$3
	fi
	LIBS[$t_name]="Not"
	if [ `getconf WORD_BIT` = '32' ] && [ `getconf LONG_BIT` = '64' ] ; then
		if [ -s /usr/lib/x86_64-linux-gnu/$1.so ]; then
			echo /usr/lib/x86_64-linux-gnu/$1.so
			LIBS[$t_name]="Installed"
		fi
	else
		if [ -s /usr/lib/i386-linux-gnu/$1.so ]; then
			echo /usr/lib/i386-linux-gnu/$1.so
			LIBS[$t_name]="Installed"
		fi
	fi
	if [ $OS_RL = "centos" ] && [ "${LIBS[$t_name]}" = "Not" ]; then
		if [ `getconf WORD_BIT` = '32' ] && [ `getconf LONG_BIT` = '64' ] ; then
			if [ -s /usr/lib64/$1.so ]; then
				echo /usr/lib64/$1.so
				LIBS[$t_name]="Installed"
			fi
		else
			if [ -s /usr/lib/$1.so ]; then
				echo /usr/lib/$1.so
				LIBS[$t_name]="Installed"
			fi
		fi
	fi
	if [ "${LIBS[$t_name]}" = "Not" ]; then
		if [ -s $2 ]; then
			echo "$IN_DOWN/$2 [found]"
		else
			echo "Error: $IN_DOWN/$2 not found!!!download now......"
			wget_down ${DUS[$t_name]}
		fi
	fi
	echo "LIBS[$t_name]="${LIBS[$t_name]}
	#return ${LIBS[$t_name]}
}

function ProgramDownloadFiles()
{
	echo "===Check Download Files $1"
	local t_name=$1
	if [ $3 ]; then
		t_name=$3
	fi
	cd $IN_DOWN
	if [ -s $2 ]; then
		echo "$IN_DOWN/$2 [found]"
		LIBS[$t_name]="found"
	else
		echo "Error: $IN_DOWN/$2 not found!!!download now......"
		wget_down ${DUS[$t_name]}
	fi
	#return "${LIBS[$t_name]}"
}

function ProgramInstalled()
{
	echo "===ProgramInstalled $1"
	echo "$1 $2 $3"
	echo "LIBS[$1]="${LIBS[$1]}
	if [ "${LIBS[$1]}" = "Installed" ]; then
		echo "$1  Installed "
	else
		echo "tar zxvf $2"
		cd $IN_DOWN
		tar zxvf $2
		local t_name=`basename $2`
		
		t_name=$1-${VERS[$1]}
		if [ -s $t_name ]; then
			echo "-s $t_name"
		else
			t_name=$2
			t_name=${t_name%.tar.gz}
			t_name=${t_name%.tgz}
			if [ -s $t_name ]; then
				echo "-s $t_name"
			else
				t_name=${t_name%.tar.gz}
				echo "-s $t_name"
			fi
		fi
		echo "cd $t_name"
		cd $t_name
		./configure $3
		make && make install
	fi
}

function import()
{
	if [ -s $1 ]; then
		echo "$1 [found]"
		echo ". $1"
		. $1
	else
		echo "Error: $1 not found!!!"
	fi
}