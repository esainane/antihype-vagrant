
all: deploy

bento/builds/centos-7.2.virtualbox.box:
	@which packer || ( echo "Packer needs to be installed, aborting!\nSee: https://www.packer.io/downloads.html"; false )
	cd bento; bin/bento build --only=virtualbox-iso centos-7.2-x86_64

rpmbuild: bento/builds/centos-7.2.virtualbox.box
	vagrant up buildbox

deploy: rpmbuild
	vagrant up core

clean:
	vagrant destroy
