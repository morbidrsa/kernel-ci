#!/bin/sh
set -o nounset

QEMU="qemu-system-"
ARCH="x86_64"
KERNEL=""
INITRD=""
ROOTFS=""
ROOT="/dev/vda3"

# TODO Add networking

pr_debug()
{
	echo "[DEBUG] $@"
}

pr_info()
{
	echo "[INFO] $@"
}

while getopts "a:k:i:r:hR:" opt; do
	case ${opt} in
		a)
			ARCH=$OPTARG
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

QEMU_CMD="$QEMU$ARCH"

CLI_DEFAULTS="-device piix3-usb-uhci,id=usb,bus=pci.0,addr=0x1.0x2 -device virtio-serial-pci,id=virtio-serial0,bus=pci.0,addr=0x4 -device virtio-balloon-pci,id=balloon0,bus=pci.0,addr=0x6"
CLI_HDD="-device virtio-blk-pci,scsi=off,bus=pci.0,addr=0x5,drive=drive-virtio-disk0,id=virtio-disk0,bootindex=1 -drive file=${ROOTFS},if=none,id=drive-virtio-disk0,format=qcow2 -snapshot"
CLI_SERIAL="-serial stdio -monitor none"
CLI_BOOT=""
CLI_BASE="-nographic"
CLI_KERNEL=""
CLI_INITRD=""


if [ "$KERNEL" != "" ]; then
	CLI_BOOT="-append 'root=$ROOT ro console=ttyS0 quiet rdinit=/bin/init'"
	CLI_KERNEL="-kernel $KERNEL"
	pr_info "Linux kernel to load: $KERNEL"

	if [ "$INITRD" != "" ]; then
		CLI_INITRD="-initrd $INITRD"
		pr_info "Initramfs to load: $INITRD"
	fi
else
	pr_info "[INFO] Use kernel available in the image"
fi


CMD="${QEMU_CMD}	\
	${CLI_BASE}	\
	${CLI_KERNEL}	\
	${CLI_INITRD}	\
	${CLI_BOOT}	\
	${CLI_SERIAL}	\
	${CLI_HDD}"

pr_info $CMD
eval $CMD
