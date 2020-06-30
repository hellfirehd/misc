#!ipxe
set base-url http://releases.rancher.com/os/latest
kernel ${base-url}/vmlinuz rancher.state.dev=LABEL=RANCHER_STATE rancher.state.autoformat=[/dev/sda] -- rancher.cloud_init.datasources=[url:https://gist.githubusercontent.com/hellfirehd/0f57c78151293bd43a91e1471074f981/raw/1cb41eaea2f780bd86b3ad40e35bab3c9b02a1e7/ipxe.boot]
initrd ${base-url}/initrd
boot
