#!/bin/sh
#
# Copyright (c) 2015 SUSE Linux GmbH
#
# This file is part of the kernel-ci project and licensed under the GNU GPLv2
#

set -o nounset

source ./lib.sh

cleanup() 
{
	pr_debug "Cleaning up"
	rm -f $IMAGE
	rm -rf initrd*
}

usage()
{
	echo "$(basename $0) [-d] [-a ARCH] -k <kerneldir> -i <master-image> [-r <root>]" >&2
	echo "  -a	Set QEMU architecture (default: x86_64)." >&2
	echo "  -d	Enable debug output." >&2
	echo "  -k	Directory from where to use the kernel." >&2
	echo "  -i	HDD image to use." >&2
	echo "  -r      root partition name." >&2
}

KERNELDIR=""
MODULES="virtio.ko virtio_ring.ko virtio_pci.ko virtio_blk.ko raid6_pq.ko xor.ko btrfs.ko"
MASTER=""
IMAGE=""
ROOT=
ARCH=x86_64
TIMEOUT=60

trap cleanup EXIT

while getopts "a:dk:i:r:t:h?" opt; do
	case ${opt} in
		a)
			ARCH=$OPTARG
			;;
		d)
			DEBUG=1
			;;
		k)
			KERNELDIR=$OPTARG
			;;
		i)
			MASTER=$OPTARG
			;;
		r)
			ROOT=$OPTARG
			;;
		t)
			TIMEOUT=$OPTARG
			;;
		h)
			usage
			exit 1
			;;
	esac
done

if [ x"$KERNELDIR" == "x" ]; then
	pr_err "Kernel directory not set"
	echo ""
	usage
	exit 1
fi

if [ x"$MASTER" == "x" ]; then
	pr_err "HDD Image not set"
	echo ""
	usage
	exit 1
fi

IMAGE=$MASTER.$$
cp ${MASTER} ${IMAGE}
pr_debug "Using JeOS image ${IMAGE}"
pr_debug "Creating initrd"
./create-initrd.sh -k ${KERNELDIR} ${ROOT:+-r $ROOT} -m "$MODULES" > /dev/null
pr_debug "Lunching VM"
./vm.sh -a ${ARCH} -r ${IMAGE} ${ROOT:+-R $ROOT} \
	-k $KERNELDIR/arch/x86_64/boot/bzImage -i initrd.img -t $TIMEOUT
