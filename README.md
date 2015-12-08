# kernel-ci
Build an initramdisk for a newly build kernel and run it inside QEMU.

The kernel-ci project consists of a set of shell scripts

* kernel-ci.sh
* vm.sh
* create-initrd.sh

which are used to boot-test (and probably run additional tests) a freshly
built kernel in a sealed environment.

The scripts have beek created as part of the kernel-ci project of SUSE's
Hackweek Number 13.

## kernel-ci.sh
```
kernel-ci.sh [-d] [-a ARCH] -k <kerneldir> -i <master-image>
  -a	Set QEMU architecture (default: x86_64).
  -d	Enable debug output.
  -k	Directory from where to use the kernel.
  -i	HDD image to use.
```
## vm.sh
```
vm.sh [-a arch] [-d] [-r rootfs] [-R root] -k <kernel> -i <initrd>
  -a arch         Architecture for QEMU.
  -d              Enable debug output.
  -r rootfs       Rootfs image to use.
  -R root         root= kernel cmdline option
  -k kernel       kernel image to use.
  -i initrd       initrd image to use.
```

## create-initrd.sh
```
create-initrd.sh [-k kdir ] [-m '<module[ <module>][...]'] [-r root]
  -k Directory having the kernel sources.
  -m Space separated list of kernel modules to include
     in initrd image.
  -r root= kernel option (default /dev/vda3).
```

## Example usage
The following example uses a SLES12 JeOS image in conjunction with a new
kernel to boot test.

```
./kernel-ci.sh -k ~/src/kernel-source/tmp/current/ \
	-i ~/Images/SLES12-JeOS-for-kvm-and-xen.x86_64-GM.qcow2.master
```

In the background it calls *create-initrd.sh* to create an initrd for the
kernel image including the virtio_blk.ko and btrfs.ko drivers as well as their
dependencies. Once the initrd image is created it copies the rootfs image so
eventual disk writes or misbehaving drivers won't corrupt it and pass the
kernel, initrd and the copy of the rootfs to *vm.sh* which spawns qemu to
boot the kernel.

It is usefull to not only do a bare bone boot of the kernel (which is good for
basic smoke testing) but run a set of tests (for example the xfstests test
suite) as well after boot. In order to achive this your rootfs image should
contain a systemd service or initscript to lunch the tests after successfull
bootup.
