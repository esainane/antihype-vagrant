
all: deploy

.PHONY: all clean deploy buildbox core

bento/builds/centos-7.2.virtualbox.box:
	@which packer || ( echo "Packer needs to be installed, aborting!\nSee: https://www.packer.io/downloads.html"; false )
	cd bento; bin/bento build --only=virtualbox-iso centos-7.2-x86_64

buildbox: bento/builds/centos-7.2.virtualbox.box
	if vagrant status buildbox | grep -q running; then vagrant provision buildbox; else vagrant up buildbox; fi

core: bento/builds/centos-7.2.virtualbox.box
	if vagrant status core | grep -q running; then vagrant provision core; else vagrant up core; fi

rpmbuild: buildbox libbrine/.git libbrine/*.c libbrine/*.h quassel/src | libbrine quassel
	vagrant ssh buildbox -c 'bash /vagrant/build.bash; exit $$?'
	test -d rpmbuild

deploy: rpmbuild core
	vagrant ssh core -c 'bash /vagrant/core.bash; exit $$?'

clean:
	vagrant destroy
