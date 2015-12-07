#!/bin/sh

set -o nounset

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

cleanup() 
{
	pr_debug "Cleaning up"
	rm -rf initrd*
}

usage()
{
	echo "$(basename $0) [-d] [-a ARCH] -k <kerneldir> -i <master-image>" >&2
	echo "  -a	Set QEMU architecture (default: x86_64)." >&2
	echo "  -d	Enable debug output." >&2
	echo "  -k	Directory from where to use the kernel." >&2
	echo "  -i	HDD image to use."
}

KERNELDIR=""
MODULES="virtio.ko virtio_ring.ko virtio_pci.ko virtio_blk.ko raid6_pq.ko xor.ko btrfs.ko"
#MODULES="virtio.ko virtio_ring.ko virtio_pci.ko virtio_blk.ko scsi_mod.ko sd_mod.ko libata.ko libahci.ko ahci.ko raid6_pq.ko xor.ko btrfs.ko"
MASTER=""
ARCH=x86_64

trap cleanup EXIT

while getopts "a:dk:i:h?" opt; do
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

pr_debug "Using JeOS image ${MASTER}"
pr_debug "Creating initrd"
create-initrd.sh -k ${KERNELDIR} -m "$MODULES" > /dev/null 
pr_debug "Lunching VM"
vm.sh -a ${ARCH} -r ${MASTER} -k $KERNELDIR/arch/x86_64/boot/bzImage -i initrd.img
