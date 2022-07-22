CONFIG_DESTINATION=/opt/aws/amazon-cloudwatch-agent/bin/config.json
CONFIG_SOURCE=/tmp/amazon-cloudwatch-agent-v${CLOUDWATCH_AGENT_CONFIG_VERSION}.json
DOWNLOAD_URL=https://s3.amazonaws.com/amazoncloudwatch-agent/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm
RPM_PATH=/tmp/amazon-cloudwatch-agent.rpm

touch /var/log/spacelift/{info,error}.log

curl $DOWNLOAD_URL --output $RPM_PATH
sudo rpm -U $RPM_PATH
rm $RPM_PATH
sudo cp "${CONFIG_SOURCE}" ${CONFIG_DESTINATION}
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c file:${CONFIG_DESTINATION}
