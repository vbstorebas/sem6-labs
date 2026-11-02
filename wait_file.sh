#!/bin/bash
FILE="/tmp/ready"
TIME=30
WAITER=0

if [ -f "$FILE" ]; then
	echo "$FILE уже существует"
	exit 0
fi
while [ $WAITER -lt $TIME ]; do
	sleep 2
	WAITER=$((2+WAITER))
	if [ -f "$FILE" ]; then
		echo "$FILE появился. Ожидание $WAITER секунд"
		exit 0
	fi
done
echo "Файл не появился. $TIME секунд прошло" >&2
exit 1
