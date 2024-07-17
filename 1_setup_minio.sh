#!/bin/bash

#########################################################################################
#  install some OS utilities 
#########################################################################################
sudo apt update
sudo apt-get install wget curl awscli mlocate -y

#########################################################################################
#  download minio debian package
#########################################################################################
wget https://dl.min.io/server/minio/release/linux-amd64/archive/minio_20230112020616.0.0_amd64.deb -O minio.deb

##########################################################################################
#   install minio
##########################################################################################
sudo dpkg -i minio.deb

##########################################################################################
#  create directory for minio data to be stored
##########################################################################################
sudo mkdir -p /opt/app/minio/data

sudo groupadd -r minio-user
sudo useradd -M -r -g minio-user minio-user

##########################################################################################
# grant permission to this directory to minio-user
##########################################################################################

sudo chown -R minio-user:minio-user /opt/app/minio/

##########################################################################################
#  create an enviroment variable file for minio
##########################################################################################

cat <<EOF > ~/minio.properties
# MINIO_ROOT_USER and MINIO_ROOT_PASSWORD sets the root account for the MinIO server.
# This user has unrestricted permissions to perform S3 and administrative API operations on any resource in the deployment.
# Omit to use the default values 'minioadmin:minioadmin'.
# MinIO recommends setting non-default values as a best practice, regardless of environment

#MINIO_ROOT_USER=myminioadmin
#MINIO_ROOT_PASSWORD=minio-secret-key-change-me

MINIO_ROOT_USER=minioroot
MINIO_ROOT_PASSWORD=supersecret1

# MINIO_VOLUMES sets the storage volume or path to use for the MinIO server.

#MINIO_VOLUMES="/mnt/data"
MINIO_VOLUMES="/opt/app/minio/data"

# MINIO_SERVER_URL sets the hostname of the local machine for use with the MinIO Server
# MinIO assumes your network control plane can correctly resolve this hostname to the local machine

# Uncomment the following line and replace the value with the correct hostname for the local machine.

#MINIO_SERVER_URL="http://minio.example.net"
EOF

##########################################################################################
#   move this file to proper directory
##########################################################################################
sudo mv ~/minio.properties /etc/default/minio

sudo chown root:root /etc/default/minio

##########################################################################################
#  start the minio server:
##########################################################################################
sudo systemctl start minio.service


##########################################################################################
#  install the 'MinIO Client' on this server 
##########################################################################################
#curl https://dl.min.io/client/mc/release/linux-amd64/mc \ (this was the original line - updated 3.13.2024)
curl https://dl.min.io/client/mc/release/linux-amd64/archive/mc.RELEASE.2023-01-11T03-14-16Z \
  --create-dirs \
  -o $HOME/minio-binaries/mc

chmod +x $HOME/minio-binaries/mc
export PATH=$PATH:$HOME/minio-binaries/

##########################################################################################
#  create an alias on this host for the minio cli (using the minio root credentials)
##########################################################################################
mc alias set local http://127.0.0.1:9000 minioroot supersecret1
#
###########################################################################################
##  lets create a user for iceberg metadata & tables using the minio cli and the  alias we just set
###########################################################################################
mc admin user add local icebergadmin supersecret1!
#
###########################################################################################
##  need to add the 'readwrite' minio policy to this new user: (these are just like aws policies)
###########################################################################################
mc admin policy set local readwrite user=icebergadmin
#
###########################################################################################
##  create a new alias for this admin user:
###########################################################################################
mc alias set icebergadmin http://127.0.0.1:9000 icebergadmin supersecret1!
#
###########################################################################################
##  create new 'Access Keys' for this user and redirect output to a file for automation later
###########################################################################################
mc admin user svcacct add icebergadmin icebergadmin >> ~/minio-output.properties
#
###########################################################################################
##  create a bucket as user icebergadmin for our iceberg data
###########################################################################################
mc mb icebergadmin/iceberg-data icebergadmin
#
###########################################################################################
##  let's reformat the output of access keys from an earlier step
###########################################################################################
sed -i "s/Access Key: /access_key=/g" ~/minio-output.properties
sed -i "s/Secret Key: /secret_key=/g" ~/minio-output.properties
#
###########################################################################################
##  let's  read the update file into memory to use these values to set aws configure
###########################################################################################
. ~/minio-output.properties
#
###########################################################################################
##  let's set up aws configure files from code (this is using the minio credentials) - The default region doesn't get used in minio
###########################################################################################
aws configure set aws_access_key_id $access_key
aws configure set aws_secret_access_key $secret_key
aws configure set default.region us-east-1
#
###########################################################################################
##  let's test that the aws cli can list our buckets in minio:
###########################################################################################
aws --endpoint-url http://127.0.0.1:9000 s3 ls
#
echo

bash -l

