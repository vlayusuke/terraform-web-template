#!/bin/bash

# This script is used to install the IAM SSH agent on the bastion host.
cd /
aws s3 cp s3://${bucket}/aws-ec2-ssh.conf /etc/
git clone https://github.com/widdix/aws-ec2-ssh.git
cd aws-ec2-ssh

./install.sh
sh /opt/import_users.sh
