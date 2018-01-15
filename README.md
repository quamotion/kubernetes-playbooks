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

The playbooks expect you to configure your hosts (master and nodes) in `hosts`, and that there is a `deployer` account on all your hosts for which you have a SSH key and passwordless-sudo is enabled. You can use [create-deployer.yml](create-deployer.yml) to create such an account.

Then:
* Use [prepare-cluster-node.yml](prepare-cluster-node.yml) to install Docker and Kubernetes on a new cluster node. You should run this
  playbook on all your nodes.
  This playbook is idempotent; you can apply it multiple times to the same node and get the same state.
* Use [create-cluster.yml](create-cluster.yml) to initialize your cluster master. You should run this playbook only once on your
  master node. If you re-run this script, changes are that your Kubernetes configuration is overwritten.
  If you want to re-create your cluster from scratch, run `sudo kubeadm reset` first.
* Use [join-cluster.yml] to add nodes to your cluster.
* Use [enable-feature-flags.yml](enable-feature-flags.yml) to enable the MountPropagation feature flags in Kubernetes
* Use [configure-cluster.yml](configure-cluster.yml) to configure your cluster. This includes installing Helm and the
  Kubernetes Dashboard.
  Note: The Ansible plugin for Helm depends on pygit2, which brings in Python and some additional dependencies.
* Use [destroy-cluster.yml](destroy-cluster.yml) to completely destroy your cluster. You can then start from scratch.
