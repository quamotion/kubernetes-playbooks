#!/bin/sh

ansible-playbook prepare-cluster-node.yml
ansible-playbook initialize-master.yml
ansible-playbook join-cluster.yml
ansible-playbook wait-for-cluster-ready.yml
ansible-playbook enable-feature-flags.yml
