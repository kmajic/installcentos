#!/bin/bash

# trying to setup an Openshift installation with 1 master, 1 NFS server for persistent storage and several nodes. 
# This script is used to install/setup the NFS server on a fresh CentOS 7 with only the following performed:
# yum -y update; reboot
# a separate script is used to setup NFS clients (install_nfs_client.sh)

read -rp "shared folder on the NFS server (full path): " choice; export NFS_FOLDER=$choice
read -rp "How many servers will be accessing (integer): " choice; export NUMBER=$choice

touch /root/temp_file.ip
echo "" > /root/temp_file.ip

for i in `seq 1 $NUMBER`; do read -rp "IP of the connecting server ($i): " choice; echo $choice >> /root/temp_file.ip; done

yum -y install nfs-utils libnfsidmap 

systemctl enable rpcbind
systemctl enable nfs-server
systemctl start rpcbind
systemctl start nfs-server
systemctl start rpc-statd
systemctl start nfs-idmapd

mkdir $NFS_FOLDER
chmod 777 $NFS_FOLDER

for i in `cat /root/temp_file.ip`; do echo -e "$NFS_FOLDER\t$i(rw,sync,all_squash)" >> /etc/exports; done
rm -f /root/temp_file.ip

##### opening the port 2049 in the firewall #######

### below works if firewalld is running over iptables. However, I commented it out and edited itpables directly
#systemctl unmask firewalld
#systemctl enable firewalld
#systemctl restart firewalld
#firewall-cmd --permanent --add-port=2049/tcp
#firewall-cmd --reload

sed -i s'/-A INPUT -i lo -j ACCEPT/-A INPUT -i lo -j ACCEPT\n-A INPUT -p tcp -m state --state NEW -m tcp --dport 2049 -j ACCEPT/' /etc/sysconfig/iptables
systemctl restart iptables
###################################################

exportfs -r

showmount -e localhost
echo ""
