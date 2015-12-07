#!/bin/sh

DEBUG=0

pr_info()
{
	echo "[INFO] $@"
}

pr_err()
{
	echo "[ERROR] $@"
}

pr_debug()
{
	if [ $DEBUG == 1 ]; then
		echo "[DEBUG] $@"
	fi
}
