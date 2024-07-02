# Deterministic upgrades through versioned repositories usage
sudo dnf upgrade -y --releasever="latest"

# We need it for binary verification.
sudo dnf swap -y gnupg2-minimal gnupg2-full

# We need it for service management.
sudo dnf install -y chkconfig
