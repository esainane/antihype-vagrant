# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'ipaddr'

VM_SUBNET = IPAddr.new "10.8.41.0/24"
$nip = VM_SUBNET.succ
def next_ip
  return ($nip = $nip.succ).to_s
end

def define(config, name)
  i = next_ip
  config.vm.define name do |nvm|
    nvm.vm.hostname = name
    nvm.vm.network :private_network, ip: i
  end
end

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box_url = "bento/builds/centos-7.2.virtualbox.box"
  config.vm.box = "Centos-7.2_x84_64"
  config.vm.boot_timeout = 900

  config.vm.synced_folder ".", "/vagrant"

  config.vm.provider "virtualbox" do |v|
    v.memory = 8192
    v.gui = true
  end

  define config, 'buildbox'

  define config, 'core'

  define config, 'skc'
end
