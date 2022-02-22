# This script installs the gVisor.
set -e

ARCH=$(uname -m)
GVISOR_VERSION="20220103"
URL=https://storage.googleapis.com/gvisor/releases/release/${GVISOR_VERSION}/${ARCH}

wget ${URL}/runsc ${URL}/runsc.sha512 ${URL}/containerd-shim-runsc-v1 ${URL}/containerd-shim-runsc-v1.sha512
sha512sum -c runsc.sha512 -c containerd-shim-runsc-v1.sha512
rm -f *.sha512

chmod a+rx runsc containerd-shim-runsc-v1
sudo mv runsc containerd-shim-runsc-v1 /usr/local/bin

sudo /usr/local/bin/runsc install -- --fsgofer-host-uds
sudo systemctl restart docker
