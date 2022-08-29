# -*- mode: ruby -*-
# vi: set ft=ruby :
TOKEN = "92zwly.w6fdrnrg2fut5xko"
MASTER_IP = "10.0.0.200"

# https://docs.vagrantup.com.
Vagrant.configure("2") do |config|
  config.vm.box = "bento/ubuntu-20.04"
  config.vm.box_check_update = false

  config.vm.provider "virtualbox" do |provider|
    provider.memory = 2048
    provider.cpus = 2
  end

  config.vm.provision "shell", path: "ubuntu/common.sh"

  config.vm.define "master" do |master|
    master.vm.hostname = "master-node"
    master.vm.network :private_network, ip: MASTER_IP
    master.vm.provision "shell", path: "master.sh",
      env: { "MASTER_IP" => MASTER_IP, "TOKEN" => TOKEN }
  end

  config.vm.define "worker1" do |master|
    master.vm.hostname = "worker-node1"
    master.vm.network :private_network, ip: "10.0.0.201"
    master.vm.provision "shell", path: "worker.sh",
      env: { "MASTER_IP" => MASTER_IP, "TOKEN" => TOKEN }
  end

  config.vm.define "worker2" do |master|
    master.vm.hostname = "worker-node2"
    master.vm.network :private_network, ip: "10.0.0.202"
    master.vm.provision "shell", path: "worker.sh",
      env: { "MASTER_IP" => MASTER_IP, "TOKEN" => TOKEN }
  end
end
