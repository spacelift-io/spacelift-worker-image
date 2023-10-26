# This script installs and starts Docker.

sudo dnf install -y docker
sudo systemctl enable --now docker
