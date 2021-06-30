# This script installs and starts Docker.

sudo amazon-linux-extras install docker
sudo systemctl enable docker
sudo service docker start
