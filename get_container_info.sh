
# check argument
if [ $# -ne 1 ]; then
   echo "Usage: $0 [container name]"
   exit 1
fi
CONTAINER_NAME=$1
LXC_INFO="sudo lxc-info -n $CONTAINER_NAME"
LXC_ATTACH="sudo lxc-attach -n $CONTAINER_NAME -- bash -c"

# check if container is running
if ! ( $LXC_INFO | grep "RUNNING" > /dev/null 2>&1 ); then
   echo "in"
   echo "Container $CONTAINER_NAME not running"
   exit 1
fi

# print health information
$LXC_ATTACH "cat /proc/meminfo" | grep "MemTotal" | awk '{ print $2 / 1024 }'

