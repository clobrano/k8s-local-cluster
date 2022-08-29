Damn simple repository to create a three node local Kubernetes cluster with Virtual Machines.

There are some other resources more flexible and complex than this one, you should check them for sure.

With flexibility comes complexity as well and the content is less clear to understand. What I want with this repository is to be dead simple to read, and so to understand what needs to build a simple cluster.

There will be some complexity ahead hovewer.
- Currently only Virtualbox is supported: I want to support libvirtd/kvm as well
- Nodes are Ubuntu based: I want to support also Fedora nodes

# Usage
All the dependency should be handled by `host-install-dependencies.sh` script, which is Ubuntu based (see points above).
So you only need to issue:

```bash
$ vagrant up
```
