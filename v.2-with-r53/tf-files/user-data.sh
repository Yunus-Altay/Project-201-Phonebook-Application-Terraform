#! /bin/bash
dnf update -y
dnf install pip -y
pip3 install flask
pip3 install flask_mysql
dnf install git -y
TOKEN=${user-data-git-token}
USER=${user-data-git-name}
cd /home/ec2-user && git clone https://$TOKEN@github.com/$USER/Project-201-Phonebook-Application-Terraform.git
python3 /home/ec2-user/Project-201-Phonebook-Application-Terraform/v.2-with-r53/phonebook-app.py