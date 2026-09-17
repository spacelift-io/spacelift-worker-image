# We need it for binary verification.
sudo dnf swap -y gnupg2-minimal gnupg2-full

# We need it for service management.
# tar and zstd extract the gVisor release archive.
sudo dnf install -y chkconfig tar zstd
