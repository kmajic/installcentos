#!/bin/bash

# trying to setup an Openshift installation with 1 master, 1 NFS server for persistent storage and 3 nodes. 
# This script is used to install/setup NFS clients on a fresh CentOS 7 with only the following performed:
# yum -y update; reboot

read -rp "shared folder on the NFS server (full path): " choice; export NFS_FOLDER=$choice; echo $NFS_FOLDER;
read -rp "How many servers will be accessing (integer): " choice; export NUMBER=$choice;

for i in `seq 1 $NUMBER`; do read -rp "IP of the connecting server ("$NUMBER"): " choice; export NFS_IP$NUMBER=$choice; done

yum -y install nfs-utils libnfsidmap 

systemctl enable rpcbind
systemctl enable nfs-server
systemctl start rpcbind
systemctl start nfs-server
systemctl start rpc-statd
systemctl start nfs-idmapd

mkdir $NFS_FOLDER
chmod 777 $NFS_FOLDER

for i in `seq 1 $NUMBER`; do echo -e "$NFS_FOLDER\t$NFS_IP$NUMBER(rw,sync,all_squash)" >> /etc/exports; done
exportfs -r

showmount -e [$NFS_IP]
