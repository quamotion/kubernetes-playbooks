# Automated Kubernetes Cluster deployment with dnsmasq and Ansible

This repository contains:
- Steps for automating the deployment of Ubuntu servers using dnsmasq and PXE.
- Ansible playbooks which allow you to set up and destroy Kubernetes cluster nodes.

## Requirements

You'll need one server machine on which you install dnsmasq, nginx (or any HTTP server) and Ansible.

To install ansible:

```
sudo apt-get install -y software-properties-common
sudo apt-add-repository -y ppa:ansible/ansible
sudo apt-get update
sudo apt-get install ansible
```

For nginx and dnsmasq, you can just run 
```
sudo apt-get install -y dnsmasq ansible nginx
```

### dnsmasq configuration

This configuration uses dnsmasq for DHCP and TFTP (used by PXE). 

You `/etc/dnsmasq.conf` file may look like this:

```
interface=enp1s0

server=8.8.8.8
server=8.8.4.4

dhcp-range=192.168.10.50,192.168.10.150,12h
dhcp-option=option:router,192.168.10.1

dhcp-host=f4:4d:30:6c:31:ab,192.168.10.201
dhcp-host=F4:4D:30:6C:35:49,192.168.10.202
dhcp-host=F4:4D:30:6C:31:EC,192.168.10.203

# https://www.freesoftwareservers.com/wiki/pxe-boot-ubuntu-16-04-dnsmasq-3735755.html
# https://blogging.dragon.org.uk/howto-setup-a-pxe-server-with-dnsmasq/
enable-tftp
tftp-root=/tftp
dhcp-boot=pxelinux.0
```

To create your `/tftp` folder, run:

```
sudo mkdir -p /tftp
cd /tftp
wget http://archive.ubuntu.com/ubuntu/dists/xenial-updates/main/installer-amd64/current/images/hwe-netboot/netboot.tar.gz
tar xf netboot.tar.gz
```

To add an option to automatically install Ubuntu using a preseed file, add this to `/tftp/ubuntu-installer/amd64/boot-screens/txt.cfg`:

```
label install
        menu label ^Kubernetes cluster
        menu default
        kernel ubuntu-installer/amd64/linux
        append auto=true priority=critical tasks=standard pkgsel/language-pack-patterns= pkgsel/install-language-support=false vga=788 initrd=ubuntu-installer/amd64/initrd.gz url=http://192.168.10.10/preseed.cfg --- quiet
```

And make it default adding a timeout to `/tftp/pxelinux.cfg/default`:

```
timeout 30
```

## Playbook overview

### Bootstrap playbooks

The bootstrap playbooks start from an Ubuntu machine as deployed via PXE. They create the deployer account and disable the default `quamotion` account.

### Configuration playbooks
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

### Reboot playbook

The reboot playbook reboots your machine using iPXE. Be careful, it will cause your machine to be wiped!

### Running playbooks

```
ansible-playbook -K prepare-cluster-node.yml
```
