# ansible-tripleo
A set of playbooks to install TripleO on a set of baremetal hosts.

# Why am I doing this?
I found a lot of documentation and automation for doing virtualized POC-like deployments via RDO, etc,
but not a lot for running vanilla TripleO on baremetal in a "production-like" environment. 

I am currently battle-testing these playbooks against a baremetal environment where I work in our
non-prod environment. 

Currently, I do not have automation around a virtualized lib-virt setup, but may 
create some in the future.

These playbooks are based off the installation instructions here.
http://docs.openstack.org/developer/tripleo-docs/installation/installation.html
