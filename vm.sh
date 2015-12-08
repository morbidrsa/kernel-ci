#!/bin/sh
#
# Copyright (c) 2015 SUSE Linux GmbH
#
# This file is part of the kernel-ci project and licensed under the GNU GPLv2
#
set -o nounset

source ./lib.sh

QEMU="qemu-system-"
ARCH="x86_64"
KERNEL=""
INITRD=""
ROOTFS=""
ROOT="/dev/vda3"

# TODO Add networking

usage()
{
	prog=$(basename $0)
	echo "$prog [-a arch] [-d] [-r rootfs] [-R root] -k <kernel> -i <initrd>" >&2
	echo "  -a arch         Architecture for QEMU." >&2
	echo "  -d              Enable debug output." >&2
	echo "  -r rootfs       Rootfs image to use." >&2
	echo "  -R root         root= kernel cmdline option" >&2
	echo "  -k kernel       kernel image to use." >&2
	echo "  -i initrd       initrd image to use." >&2
}

while getopts "da:k:i:r:hR:" opt; do
	case ${opt} in
		a)
			ARCH=$OPTARG
			;;
		d)
			DEBUG=$OPTARG
			;;
		k)
			KERNEL=$OPTARG
			;;
		i)
			INITRD=$OPTARG
			;;
		r)
			ROOTFS=$OPTARG
			;;
		R)
			ROOT=$OPTARG
			;;
		h)
			usage
			exit 1
			;;
	esac
done

if [ x"$KERNEL" == "x" ]; then
	pr_err "No kernel option given"
	usage
	exit 1
fi

if [ x"$ROOTFS" == "x" ]; then
	pr_err "No rootfs option given"
	usage
	exit 1
fi

if [ x"$INITRD" == "x" ]; then
	pr_err "No initrd option given"
	usage
	exit 1
fi

QEMU_CMD="$QEMU$ARCH"

QEMU_DEFAULTS="-device virtio-serial-pci,id=virtio-serial0,bus=pci.0,addr=0x4 -device virtio-balloon-pci,id=balloon0,bus=pci.0,addr=0x6"
QEMU_HDD="-device virtio-blk-pci,scsi=off,bus=pci.0,addr=0x5,drive=drive-virtio-disk0,id=virtio-disk0,bootindex=1 -drive file=${ROOTFS},if=none,id=drive-virtio-disk0,format=qcow2 -snapshot"
QEMU_SERIAL="-serial stdio -monitor none"
QEMU_BOOT=""
QEMU_BASE="-nographic"
QEMU_KERNEL=""
QEMU_INITRD=""

QEMU_BOOT="-append 'root=$ROOT ro console=ttyS0 quiet rdinit=/bin/init'"
QEMU_KERNEL="-kernel $KERNEL"
pr_debug "Linux kernel to load: $KERNEL"

QEMU_INITRD="-initrd $INITRD"
pr_debug "Initramfs to load: $INITRD"

CMD="${QEMU_CMD}	\
	${QEMU_BASE}	\
	${QEMU_KERNEL}	\
	${QEMU_INITRD}	\
	${QEMU_BOOT}	\
	${QEMU_SERIAL}	\
	${QEMU_HDD}"

pr_debug $CMD
eval $CMD
