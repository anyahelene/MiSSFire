#!/bin/bash

if [ ! -f config/default-config.sh ]; then
	echo config/default-config.sh not found
	exit 1
fi

. config/default-config.sh
[ -f config/config.sh ] && . config/config.sh

function show_config {
   echo "MTLS=$MTLS"
   echo "TOKEN=$TOKEN"
   echo "WORKERS=$WORKERS"
   echo "CLIENTS=$CLIENTS"
}

function show_paths {
echo "MISSFIRE=\"$MISSFIRE\""
echo "BANK=\"$BANK\""
echo
echo "MISSFIRE_SERVICES=\"$MISSFIRE_SERVICES\""
echo "BANK_SERVICES=\"$BANK_SERVICES\""
echo
echo "MISSFIRE_COMMONS=\"$MISSFIRE_COMMONS\""
echo "BANK_COMMONS=\"$BANK_COMMONS\""
echo
echo "MISSFIRE_CLIENT_DOCKER_IMAGE=\"$MISSFIRE_CLIENT_DOCKER_IMAGE\""
echo "MISSFIRE_SERVICES_DOCKER_IMAGE=\"$MISSFIRE_SERVICES_DOCKER_IMAGE\""
echo
echo "DOCKER_YML=\"$DOCKER_YML\""
echo "DOCKER_YML_ORIGINAL=\"$DOCKER_YML_ORIGINAL\""
}
function arg_parse {
	usage="$(basename "$0") [-h] [-m True|False (Enable/Disable MTLS)] [-t True|False (Enable/Disable Tokens)] [-w NUM (Number of server workers)] [-c NUM (Number of client processes)]"

	while getopts 'hm:t:w:c:' option; do
		case "$option" in
			h) echo "$usage"
			   echo "defaults: "
			   exit
			   ;;
			m) if [ "$OPTARG" != "True" -a "$OPTARG" != "False" ]; then
				echo "argument to -m should be True or False"
				exit 1
			   fi
			   MTLS=$OPTARG
			   ;;
			t) if [ "$OPTARG" != "True" -a "$OPTARG" != "False" ]; then
				echo "argument to -t should be True or False"
				exit 1
			   fi
			   TOKEN=$OPTARG
			   ;;
			w) WORKERS=$OPTARG
			   ;;
			c) CLIENTS=$OPTARG
			   ;;
			\?) echo "Invalid option: -$OPTARG" >&2
			   exit 1
			   ;;
		esac
	done
}

function check_dir {
	if [ ! -d "$1" ]; then
		echo Directory $1 not found
		exit 1
	fi
}

function check_file {
	if [ ! -f "$1" ]; then
		echo File $1 not found
		exit 1
	fi
}

arg_parse "$@"
show_config

echo Checking...
[ ! -z "$MISSFIRE" ] && check_dir $MISSFIRE
check_dir $BANK
check_dir $MISSFIRE_SERVICES
check_dir $BANK_SERVICES
check_dir $MISSFIRE_COMMONS
check_dir $BANK_COMMONS
check_dir $MISSFIRE_CLIENT_DOCKER_IMAGE
check_dir $MISSFIRE_SERVICES_DOCKER_IMAGE
check_file $DOCKER_YML

GUNICORN_CONFIG_PY="$BANK_COMMONS/general/gunicorn_config.py"
CLIENT_PY="$BANK/client/client.py"
check_file $GUNICORN_CONFIG_PY
check_file $CLIENT_PY

show_config > config/config.sh
echo >> config/config.sh
show_paths >> config/config.sh

DEBUG=True
echo editing $DOCKER_YML
sed -i.bak -e "s/MTLS=.*$/MTLS=$MTLS/" -e "s/TOKEN=.*$/TOKEN=$TOKEN/" -e "s/_DEBUG=.*$/_DEBUG=$DEBUG/" $DOCKER_YML
echo editing $GUNICORN_CONFIG_PY
sed -i.bak -e "s/^.*workers *= *.*$/workers = $WORKERS/" $GUNICORN_CONFIG_PY
echo editing $CLIENT_PY
sed -i.bak -e "s/^    numProcesses =.*$/    numProcesses = $CLIENTS/" -e "s/^ *IS_MISSFIRE *= *.*$/IS_MISSFIRE = $MTLS/" -e "s/^ *IS_MISSFIRE_TOKEN *= *.*$/IS_MISSFIRE_TOKEN = $TOKEN/" $CLIENT_PY
sed -e "s/^    numProcesses =.*$/    numProcesses = 1/" -e "s/^ *IS_MISSFIRE *= *.*$/IS_MISSFIRE = $MTLS/" -e "s/^ *IS_MISSFIRE_TOKEN *= *.*$/IS_MISSFIRE_TOKEN = $TOKEN/" $CLIENT_PY > "$BANK/client/client_1.py"

echo Reconfigure successful. To rebuild docker images, please run:
echo
[ "$MISSFIRE" != "." ] && echo "  cd $MISSFIRE"
echo "  ./build.sh -d"
echo "  ./build.sh -i"
echo "  ./build.sh -c"
echo
echo Rebuild and start the bank server with:
echo "  ( cd $BANK_SERVICES ; ./build.sh -r )"
echo
echo Start the bank client with:
echo "  ( cd $BANK/client ; python client.py )"
