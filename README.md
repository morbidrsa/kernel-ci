# kernel-ci
Build an initramdisk for a newly build kernel and run it inside QEMU

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
