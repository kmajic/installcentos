#!/bin/bash

# trying to setup an Openshift installation with 1 master, 1 NFS server for persistent storage and 3 nodes. 
# This script is used to install/setup NFS clients on a fresh CentOS 7 with only the following performed:
# yum -y update; reboot

read -rp "IP of the NFS server: " choice; export NFS_IP=$choice;
read -rp "shared folder on the NFS server (full path): " choice; export NFS_FOLDER=$choice; echo $NFS_FOLDER;

yum -y install nfs-utils libnfsidmap 
systemctl enable rpcbind; systemctl start rpcbind

mkdir $NFS_FOLDER
echo -e "$NFS_IP:$NFS_FOLDER\t$NFS_FOLDER\t nfs \t defaults \t 0 0" >> /etc/fstab; mount -a
df -hT
