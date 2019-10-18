#/usr/bin/env bash
PRIVIPS=$(
for ifcfg in $(ifconfig -lu);

  do ifconfig $ifcfg | grep -v inet6 | awk -v ifcfg=$ifcfg '/inet6?/{print ifcfg ": " $2 " | "}' | grep -v lo;

done
)

echo $PRIVIPS
