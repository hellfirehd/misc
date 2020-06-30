#!ipxe
set base-url http://releases.rancher.com/os/latest
kernel ${base-url}/vmlinuz rancher.state.dev=LABEL=RANCHER_STATE rancher.state.autoformat=[/dev/sda] -- rancher.cloud_init.datasources=[url:https://raw.githubusercontent.com/hellfirehd/misc/master/cloud-config.yml]
initrd ${base-url}/initrd
boot
