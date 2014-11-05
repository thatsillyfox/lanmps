# Sphinx install function
function Install_Sphinx {
	local IN_LOG=$LOGPATH/install_Install_Sphinx_${SPHINX_ID}.sh.lock
	echo
    [ -f $IN_LOG ] && return
	echo "============================Install Sphinx >> ${SPHINX_ID} ================================="
	
	import "${IN_PWD}/lib/Install_Sphinx_${SPHINX_ID}.sh"
	
	echo "============================Install Sphinx >> ${SPHINX_ID}================================="
	touch $IN_LOG
}