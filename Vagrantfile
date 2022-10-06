# -*- mode: ruby -*-
# vi: set ft=ruby :
TOKEN = "92zwly.w6fdrnrg2fut5xko"
MASTER_IP = "10.0.0.200"
WORKERS_NO = 2

# https://docs.vagrantup.com.
Vagrant.configure("2") do |config|
  config.vm.box = "centos/7"
  config.vm.box_check_update = false

  config.vm.provider "virtualbox" do |provider|
    provider.memory = 2048
    provider.cpus = 2
  end

  config.vm.provider "libvirt" do |provider|
    provider.cpu_mode = 'host-passthrough'
    provider.graphics_type = 'none'
    provider.memory = 2048
    provider.cpus = 4
    provider.qemu_use_session = false
  end

  config.vm.provision "shell", path: "centos-guest-dependencies.sh"
  config.vm.provision "shell", path: "containerd-install.sh"
  config.vm.provision "shell", path: "install-runc.sh"
  config.vm.provision "shell", path: "network-setup.sh"
  config.vm.provision "shell", path: "containerd-toml.sh"
  config.vm.provision "shell", path: "k8s-install.sh"
  config.vm.provision "shell", path: "swap-disable.sh"

  config.vm.define "master" do |master|
    master.vm.hostname = "master-node"
    master.vm.network :private_network, ip: MASTER_IP
    master.vm.provision "shell", path: "master.sh",
      env: { "MASTER_IP" => MASTER_IP, "TOKEN" => TOKEN }
  end

  (1..WORKERS_NO).each do |i|
    config.vm.define "worker#{i}" do |master|
      master.vm.hostname = "worker-node#{i}"
      master.vm.network :private_network, ip: "10.0.0.20#{i}"
      master.vm.provision "shell", path: "worker.sh",
        env: { "MASTER_IP" => MASTER_IP, "TOKEN" => TOKEN }
    end
  end
end
