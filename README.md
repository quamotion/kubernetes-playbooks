# kubernetes-playbooks

This repository contains Ansible playbooks which allow you to set up Kubernetes cluster nodes.
They assume you've got a vanilla Ubuntu Server 16.04 installation and take it from there.

You'll need to install Ansible first:

```
sudo apt-get install -y software-properties-common
sudo apt-add-repository -y ppa:ansible/ansible
sudo apt-get update
sudo apt-get install ansible
```

Then:

```
ansible-playbook -K prepare-cluster-node.yml
```
