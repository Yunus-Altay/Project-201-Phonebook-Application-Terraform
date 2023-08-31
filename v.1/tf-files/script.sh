#!/bin/bash 
yum update -y
yum install python3 -y
yum install -y python3 python3-pip
pip3 install flask
pip3 install flask_mysql
yum install git -y
echo "${my_db_url}" > /home/ec2-user/dbserver.endpoint
TOKEN="xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
cd /home/ec2-user && git clone https://$TOKEN@github.com/Yunus-Altay/Project-201-Phonebook-Application-Terraform.git
python3 /home/ec2-user/Project-201-Phonebook-Application-Terraform/v.1/phonebook-app.py