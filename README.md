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
