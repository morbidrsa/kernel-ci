#!/bin/sh

DEBUG=0

pr_info()
{
	echo "[INFO] $@"
}

pr_err()
{
	echo "[ERROR] $@" >&2
}

pr_debug()
{
	if [ $DEBUG == 1 ]; then
		echo "[DEBUG] $@"
	fi
}
