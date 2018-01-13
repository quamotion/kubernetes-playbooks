#!/bin/sh

apt-get install -y software-properties-common
apt-add-repository ppa:ansible/ansible
apt-get update
apt-get install -y ansible

echo "vagrant:vagrant" | chpasswd

ansible-playbook -K /playbooks/prepare-cluster-node.yml --extra-vars "ansible_become_pass=vagrant"
ansible-playbook -K /playbooks/create-cluster.yml --extra-vars "ansible_become_pass=vagrant"
ansible-playbook -K /playbooks/configure-cluster.yml --extra-vars "ansible_become_pass=vagrant"
ansible-playbook -K /playbooks/enable-feature-flags.yml --extra-vars "ansible_become_pass=vagrant"