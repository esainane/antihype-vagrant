# antihype-vagrant

An attempt at creating a reproducible environment centred around quassel and libbrine

## Usage

Firstly, you'll need to clone this repository and all of its submodules:

```
git clone --recursive https://github.com/esainane/antihype-vagrant
```

If you don't have VirtualBox installed already, you'll want to [install it](https://www.virtualbox.org/wiki/Downloads). If you're using Debian, they helpfully provide a `virtualbox` package:

```
which apt && apt-get install virtualbox
```

If you don't have a copy of packer installed already, you'll need to [grab a release for the system of your choice](https://www.packer.io/downloads.html), in order to build the base VM images:

```
wget https://releases.hashicorp.com/packer/0.8.6/packer_0.8.6_linux_amd64.zip
PACKER_EXTRACT="$(pwd)"
unzip packer_0.8.6_linux_amd64.zip
```

Set up the virtual machines. On the first run, bento will need to create a base image for vagrant to use. If you don't want to add packer to your PATH for the long term, you'll need to add it to your path for the first make run.

```
PATH="$PACKER_EXTRACT/packer:$PATH" make
```

This will create a base image for, provision, and run scripts on two virtual machines:
 - A build box, which installs all of the development dependencies and generates packages.
 - A core box, which installs and configures runtime dependencies and the built packages.

The scripts could also just be run on a compatible host system, if you prefer.
