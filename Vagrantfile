# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'ipaddr'

VM_SUBNET = IPAddr.new "10.8.41.0/24"
$nip = VM_SUBNET.succ
def next_ip
  return ($nip = $nip.succ).to_s
end

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box_url = "~/bento/builds/centos-7.1.virtualbox.box"
  config.vm.box = "Centos-7.1_x84_64"
  config.vm.boot_timeout = 900

  config.vm.synced_folder ".", "/vagrant"

  config.vm.provider "virtualbox" do |v|
    v.memory = 8192
    v.gui = true
  end

  config.vm.define 'buildbox' do |nvm|
    nvm.vm.hostname = 'buildbox'
    nvm.vm.network :private_network, ip: next_ip
    nvm.vm.provision 'shell', path: 'build.bash'
  end

  config.vm.define 'core' do |nvm|
    nvm.vm.hostname = 'core'
    nvm.vm.network :private_network, ip: next_ip
    nvm.vm.provision 'shell', path: 'core.bash'
  end

  config.vm.define 'skc' do |nvm|
    nvm.vm.hostname = 'skc'
    nvm.vm.network :public_network, ip: next_ip
    nvm.vm.network :private_network

    nvm.vm.provision 'shell', path: 'skc.bash'
  end
end
