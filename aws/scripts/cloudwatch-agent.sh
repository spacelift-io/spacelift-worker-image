CONFIG_DESTINATION=/opt/aws/amazon-cloudwatch-agent/bin/config.json
CONFIG_SOURCE=/tmp/amazon-cloudwatch-agent.json

CURRENTARCH=$(uname -m)
if [ "$CURRENTARCH" = "aarch64" ] || [ "$CURRENTARCH" = "arm64" ]; then
  CURRENTARCH="arm64"
else
  CURRENTARCH="amd64"
fi

DOWNLOAD_URL=https://s3.amazonaws.com/amazoncloudwatch-agent/amazon_linux/${CURRENTARCH}/latest/amazon-cloudwatch-agent.rpm
RPM_PATH=/tmp/amazon-cloudwatch-agent.rpm

sudo touch /var/log/spacelift/{info,error}.log

curl $DOWNLOAD_URL --output $RPM_PATH
df # Temporarily, till we figure out the disk space issue
sudo rpm -U $RPM_PATH
rm $RPM_PATH
sudo mv ${CONFIG_SOURCE} ${CONFIG_DESTINATION}
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c file:${CONFIG_DESTINATION}
