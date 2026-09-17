# This script installs gVisor (runsc, the containerd shim and the gvisor-bin/
# sidecar binaries that runsc executes at runtime), following the upstream
# "Install latest release" instructions:
# https://gvisor.dev/docs/user_guide/install/
#
# gVisor ships each release as a single archive. The per-binary artifacts
# (runsc, runsc.sha512, containerd-shim-runsc-v1, ...) that this script used
# to download were retired and now return 404. runsc also expects gvisor-bin/
# next to its own binary; the auto-download fallback for a missing gvisor-bin/
# is being removed at the end of September 2026, so install the whole archive.
set -euo pipefail

CURRENTARCH=$(uname -m)
URL=https://storage.googleapis.com/gvisor/releases/release/latest/${CURRENTARCH}


WORKDIR=$(mktemp -d)
trap 'rm -rf "${WORKDIR}"' EXIT
cd "${WORKDIR}"

# --fail turns an HTTP error into a curl error instead of writing the 404 body
# to disk and surfacing later as a checksum mismatch.
curl --fail --silent --show-error --location --retry 3 \
  --remote-name-all "${URL}"/{gvisor.tar.zstd,gvisor.tar.zstd.sha512}
sha512sum -c gvisor.tar.zstd.sha512

# Archive members are already 0755; runsc looks for gvisor-bin/ beside itself.
sudo tar --zstd -xf gvisor.tar.zstd -C /usr/local/bin

sudo /usr/local/bin/runsc install -- --fsgofer-host-uds
sudo systemctl restart docker
