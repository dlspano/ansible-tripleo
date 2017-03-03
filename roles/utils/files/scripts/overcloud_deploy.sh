#!/usr/bin/env bash

ntp_server=pool.ntp.org

openstack overcloud deploy --templates \
  -e ~/templates/environments/puppet-pacemaker.yaml \
  -e ~/templates/environments/network-isolation.yaml \
  -e ~/templates/environments/network-environment.yaml \
  -e ~/templates/environments/storage-environment.yaml \
  -e ~/templates/environments/net-bond-with-vlans.yaml \
  -e ~/custom-templates/ceph_default_disks.yaml \
  -e ~/custom-templates/ceph_wipe_env.yaml \
  --control-scale 3 \
  --compute-scale 2 \
  --ceph-storage-scale 3 \
  --control-flavor control \
  --compute-flavor compute \
  --ceph-storage-flavor ceph-storage \
  --ntp-server ${ntp_server} \
  --neutron-network-type vxlan \
  --neutron-tunnel-types vxlan \
  --force-postconfig


overcloud_ips=$(openstack server list | grep overcloud | awk '{ print $8 }' | cut -d= -f2)

for overcloud_ip in ${overcloud_ips}; do
  ssh-keygen -R ${overcloud_ip}
done
