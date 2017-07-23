# OpenWrt Build

This builds a VM that can compile openwrt.  The config file builds a x86 image
for virtualbox but it can be changed.

The Vagrantfile largely follows the instructions here:

https://wiki.openwrt.org/doc/howto/build

The whole thing can take a couple of hours. If it works, at the end, there
will be an x86 folder under the `dist` folder on the host with a `vdi` file
that can be used with virtualbox

