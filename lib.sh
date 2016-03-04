#!/bin/bash
#
# Copyright (c) 2015 SUSE Linux GmbH
#
# This file is part of the kernel-ci project and licensed under the GNU GPLv2
#

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
	if [ "$DEBUG" == "-d" ]; then
		echo "[DEBUG] $@"
	fi
}
