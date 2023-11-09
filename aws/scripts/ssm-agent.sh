CURRENTARCH=$(uname -m)
if [ "$CURRENTARCH" = "aarch64" ] || [ "$CURRENTARCH" = "arm64" ]; then
  CURRENTARCH="arm64"
else
  CURRENTARCH="amd64"
fi

sudo dnf install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_${CURRENTARCH}/amazon-ssm-agent.rpm

sudo systemctl status amazon-ssm-agent
