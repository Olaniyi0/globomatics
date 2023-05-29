#!/bin/bash
sudo apt -y update
sudo apt -y install nginx
echo "export AZCOPY_AUTO_LOGIN_TYPE=MSI" | tee -a ~/.bashrc
echo "export AZCOPY_MSI_msiid=${user_assigned_identity}" | tee -a ~/.bashrc
echo "alias azcopy=./azcopy" | tee -a ~/.bashrc
source /root/.bashrc
sudo wget -O azcopy_v10.tar.gz https://aka.ms/downloadazcopy-v10-linux && tar -xf azcopy_v10.tar.gz --strip-components=1
azcopy copy https://${storage_account_name}.blob.core.windows.net/${container_name}/ . --recursive
sudo rm -r /var/www/html && sudo mv ${container_name} html && sudo cp -r html /var/www/