
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box_url = "~/bento/builds/centos-7.1.virtualbox.box"
  config.vm.box = "Centos-7.1_x84_64"
  config.vm.boot_timeout = 900

  config.vm.synced_folder ".", "/vagrant"

  config.vm.provider "virtualbox" do |v|
    v.memory = 8192
  end

  config.vm.define 'core' do |nvm|
    nvm.vm.hostname = 'core'
    nvm.vm.provision 'shell', path: 'core.bash'
  end

  config.vm.define 'skc' do |nvm|
    nvm.vm.hostname = 'skc'
    nvm.gui = true
    nvm.vm.network :public_network

    nvm.vm.provision 'shell', path: 'skc.bash'
  end
end
