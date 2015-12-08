# kernel-ci
Build an initramdisk for a newly build kernel and run it inside QEMU

## kernel-ci.sh
kernel-ci.sh [-d] [-a ARCH] -k <kerneldir> -i <master-image>
  -a	Set QEMU architecture (default: x86_64).
  -d	Enable debug output.
  -k	Directory from where to use the kernel.
  -i	HDD image to use.
