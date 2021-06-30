# This script installs the gVisor.
set -e

URL=https://storage.googleapis.com/gvisor/releases/release/latest

wget ${URL}/runsc -P /tmp
sudo mv /tmp/runsc /usr/local/bin
sudo chmod a+rx /usr/local/bin/runsc

sudo /usr/local/bin/runsc install -- --fsgofer-host-uds
sudo systemctl restart docker
