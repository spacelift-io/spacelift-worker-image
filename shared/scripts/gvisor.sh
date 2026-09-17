# This script installs gVisor (runsc, the containerd shim and the gvisor-bin/
# sidecar binaries that runsc executes at runtime).
#
# gVisor ships each release as a single archive. The per-binary artifacts
# (runsc, runsc.sha512, containerd-shim-runsc-v1, ...) that this script used
# to download were retired and now return 404. runsc also expects gvisor-bin/
# next to its own binary; the auto-download fallback for a missing gvisor-bin/
# is being removed at the end of September 2026, so install the whole archive.
set -euo pipefail

CURRENTARCH=$(uname -m)
URL=https://storage.googleapis.com/gvisor/releases/release/latest/${CURRENTARCH}

# GNU tar shells out to the bzip2 binary for -j; AL2023 minimal does not ship it.
MISSING=()
for tool in tar bzip2; do
  command -v "${tool}" >/dev/null 2>&1 || MISSING+=("${tool}")
done
if [ "${#MISSING[@]}" -gt 0 ]; then
  if command -v dnf >/dev/null 2>&1; then
    sudo dnf install -y "${MISSING[@]}"
  else
    sudo apt-get -y install "${MISSING[@]}"
  fi
fi

WORKDIR=$(mktemp -d)
trap 'rm -rf "${WORKDIR}"' EXIT
cd "${WORKDIR}"

# --fail turns an HTTP error into a curl error instead of writing the 404 body
# to disk and surfacing later as a checksum mismatch.
curl --fail --silent --show-error --location --retry 3 \
  --remote-name-all "${URL}"/{gvisor.tar.bz2,gvisor.tar.bz2.sha512}
sha512sum -c gvisor.tar.bz2.sha512

# Archive members are already 0755; runsc looks for gvisor-bin/ beside itself.
sudo tar -xjf gvisor.tar.bz2 -C /usr/local/bin

sudo /usr/local/bin/runsc install -- --fsgofer-host-uds
sudo systemctl restart docker
