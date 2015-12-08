#!/bin/sh
#
# Copyright (c) 2015 SUSE Linux GmbH
#
# This file is part of the kernel-ci project and licensed under the GNU GPLv2
#

PROGRAMS=('sh' 'cat' 'chroot' 'echo' 'insmod' 'mount' 'sleep')
#MODULES=('efivarfs.ko' 'mcb.ko' 'mcb-pci.ko')

DEFROOT="/dev/vda3"

#
# $1 program
copy_libs_for_prog()
{
	local prog libs
	prog=$1

	libs=$(ldd ${prog} | cut -d '>' -f 2 | cut -d ' ' -f 2 | grep ^/)
	for l in ${libs}; do
		cp $l lib64
	done
}

usage()
{
	echo "Usage: $1 [-k kdir ] [-m '<module[ <module>][...]'] [-r root]" >&2
	echo "" >&2
	echo "  -k Directory having the kernel sources." >&2
	echo "  -m Space separated list of kernel modules to include" >&2
	echo "     in initrd image." >&2
	echo "  -r root= kernel option (default $DEFROOT)."  >&2
	exit 1
}

program=$(basename $0)
while getopts "k:m:r:?" flag; do
	case ${flag} in
		k)
			KDIR=${OPTARG}
			;;
		m)
			MODULES=${OPTARG}
			;;
		r)
			ROOT=${OPTARG}
			;;
		?)
			usage ${program}
			;;
		*)
			echo "invalid option"
			usage ${program}
			;;
	esac
done

if [ x"$ROOT" == "x" ]; then
	ROOT=$DEFROOT
fi

rm -rf initrd
mkdir -p initrd/{bin,dev,etc,lib/modules,lib64,proc,sys,sysroot}
pushd initrd
ln -s bin sbin
pushd bin
popd

echo "#!/bin/sh" >> bin/init

for mod in ${MODULES}; do
	echo "echo \"Loading ${mod}\"" >> bin/init
	echo "insmod /lib/modules/${mod}" >> bin/init
done

cat >> bin/init << __EOF__

echo "Mounting /proc, /dev and /sys"
mount -t proc /proc /proc
mount -t sysfs /sys /sys
mount -t devtmpfs /dev /dev

# Mount rootfs to /sysroot
mount -o ro $ROOT /sysroot

echo "Switching to new root"
cd /sysroot
exec chroot . sh -c 'exec /sbin/init'

__EOF__

chmod 755 bin/init

if [ -x /usr/bin/busybox-static ]; then
	cp /usr/bin/busybox-static bin/busybox
	pushd bin
	ln -s busybox sh
	ln -s busybox insmod
	ln -s busybox mount
	ln -s busybox echo
	ln -s busybox chroot
	popd
else
	for lib in ld-2.22.so ld-linux.so.2; do
		cp /lib/${lib} lib64/
	done

	for prog in ${PROGRAMS[@]}; do
		absprog=$(which ${prog})
		if [ -z ${absprog} ]; then
			echo "${prog} not found, skipping.."
			continue
		fi
		cp ${absprog} bin/
		copy_libs_for_prog ${absprog}
	done
fi

if [ x"$KDIR" != "x" ]; then
	readlink $KDIR
	LINK=$?
	if [ $LINK -eq 0 ]; then
		KDIR="$KDIR/"
	fi
	for mod in ${MODULES}; do
		find $KDIR -name "${mod}" | xargs cp -t lib/modules/
	done
fi

find ./ | cpio -H newc -o > ../initrd.cpio 2> /dev/null
popd

gzip -9 -c initrd.cpio > initrd.img

