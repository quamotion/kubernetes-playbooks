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

## Playbook overview

* Use [prepare-cluster-node.yml](prepare-cluster-node.yml) to install Docker and Kubernetes on a new cluster node. You should run this
  playbook on all your nodes.
  This playbook is idempotent; you can apply it multiple times to the same node and get the same state.
* Use [create-cluster.yml](create-cluster.yml) to initialize your cluster master. You should run this playbook only once on your
  master node. If you re-run this script, changes are that your Kubernetes configuration is overwritten.
  If you want to re-create your cluster from scratch, run `sudo kubeadm reset` first.
