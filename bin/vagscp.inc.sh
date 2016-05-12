
_VSSH_OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"

function get_ssh_settings # $mach
{
	mach=$1
	CNF=`vagrant ssh-config $mach | cut -c3-`
	HOST=`echo "$CNF" | grep HostName | cut -f2 -d' '`
	PORT=`echo "$CNF" | grep Port | cut -f2 -d' '`
	USER=`echo "$CNF" | grep "User " | cut -f2 -d' '`
	KEYP=`echo "$CNF" | grep IdentityFile | cut -f2 -d' ' | sed "s/\"//g"`

#  echo HOST=$HOST
#	echo PORT=$PORT
#	echo USER=$USER
#	echo KEYP=$KEYP

}


# host_loc - location on host - absolute or relative path
# vagr_loc - location in vagrant - absolute path
function rsync_to # $mach, $host_loc, $vagr_loc
{
	mach=$1
	host_loc=$2
	vagr_loc=$3
	get_ssh_settings $mach

	set -x
	ssh $_VSSH_OPTS -p $PORT -i $KEYP ${USER}@${HOST} sudo chown -R $USER $vagr_loc
	rsync -avz -e "ssh -p $PORT $_VSSH_OPTS -i $KEYP" $host_loc ${USER}@${HOST}:${vagr_loc}
	set +x
}

function rsync_from # $mach, $vagr_loc, $host_loc
{
	mach=$1
	vagr_loc=$2
	host_loc=$3
	get_ssh_settings $mach

	set -x
	ssh $_VSSH_OPTS -p $PORT -i $KEYP ${USER}@${HOST} sudo chown -R $USER $vagr_loc
	rsync -avz -e "ssh -p $PORT $_VSSH_OPTS -i $KEYP" ${USER}@${HOST}:${vagr_loc} $host_loc
	set +x
}


