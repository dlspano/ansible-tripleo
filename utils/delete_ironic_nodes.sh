#!/usr/bin/env bash
# A simple script that deletes all of the ironic nodes.
# Useful when initially testing the undercloud introspection process.

nodes=$(openstack baremetal node list | grep "available\|manageable" | awk '{print $2}')

if [ ! -z $nodes ]; then
  for node in $nodes; do
    echo "Deleting node $node"
    openstack baremetal node delete $node;
  done
else
  echo "No nodes found"
fi
