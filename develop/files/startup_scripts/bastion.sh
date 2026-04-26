#!/bin/bash

# This script is used to configure the bastion host for the project.
amazon-linux-extras install -y epel
yum update -y
yum install -y epel-release jq git vim mysql python3 amazon-ssm-agent
systemctl enable amazon-ssm-agent

echo "Defaults logfile=/var/log/sudo.log" >> /etc/sudoers
echo "PROMPT_COMMAND=\"$PROMPT_COMMAND; history -a\"" >> /root/.bashprofile

cd /
aws s3 cp s3://${bastion_bucket}/install_iam_ssh.sh /
/bin/bash /install_iam_ssh.sh

reboot
