#!/usr/bin/env bash
# A simple script to check and run baremetal imports, introspection,
# and assigns the nodes to profiles

# Declare global variables
args=( "$@" )
args_length=${#args[@]}

function assign_profiles() {
  # Array of TripleO profile types
  declare -a profiles=('compute' 'control' 'ceph-storage')

  # Associative array of node name/uuid data
  declare -A node_map

  # Populate the node_map with key/value pairs of name/uuid from Openstack CLI output
  # Should look something like this:
  # node_map[7257047f-2773-4d0e-97ef-40349fcf3aae]=controller-1
  while read uuid name; do
    node_map[$name]=${uuid};
  done < <(openstack baremetal node list -f value | awk '{printf ("%s\t%s\n", $1, $2)}')

  # Assign nodes to profiles
  for profile in ${profiles[@]}; do
    echo "Starting ${profile} profile assignment"
    for node_name in ${!node_map[@]}; do
      if [[ "$node_name" == *"$profile"* ]]; then
        echo "Setting node ${node_map[$node_name]} ${node_name} to profile $profile"
        openstack baremetal node set \
        --property capabilities="profile:${profile},boot_option:local" \
        ${node_map[$node_name]}
      fi
    done
  done
}

function delete_nodes() {
  nodes=$1
  for node in $nodes; do
    echo "Deleting node $node"
    openstack baremetal node delete $node;
  done
}

function import_nodes() {
  openstack baremetal import --json ~/instackenv.json
  openstack baremetal configure boot
}

function introspect_nodes() {
  nodes="$1"
  echo "Setting nodes to manageable"
  for node in $nodes;
  do
    openstack baremetal node manage $node ;
  done
  echo "Starting introspection"
  openstack overcloud node introspect --all-manageable --provide
}

function node_uuid_list() {
  echo "$(openstack baremetal node list --fields uuid -f value)"
}

main(){
  nodes=$(node_uuid_list)

  if [ -z ${args} && ! -z ${nodes} ]; then
    for arg in ${args[@]}; do
      if [ ${arg} == "-d" ]; then
        delete_nodes $nodes
      fi
    done
  else
    echo "No nodes to delete"
  fi

  if [ ! -z ${nodes} ]; then
    # If the user specified to delete the nodes, delete them if they exist
    echo "Nodes already exist. Nothing to do."
  else
    import_nodes
    introspect_nodes $(nodes)
    assign_profiles
  fi

}

main "$@"
