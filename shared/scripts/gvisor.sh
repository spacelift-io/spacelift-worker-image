# This script installs the gVisor.
set -e

CURRENTARCH=$(uname -m)
URL=https://storage.googleapis.com/gvisor/releases/release/latest/${CURRENTARCH}

curl --remote-name-all ${URL}/{runsc,runsc.sha512,containerd-shim-runsc-v1,containerd-shim-runsc-v1.sha512}
sha512sum -c runsc.sha512 -c containerd-shim-runsc-v1.sha512
rm -f *.sha512

chmod a+rx runsc containerd-shim-runsc-v1
sudo mv runsc containerd-shim-runsc-v1 /usr/local/bin

sudo /usr/local/bin/runsc install -- --fsgofer-host-uds
sudo systemctl restart docker
