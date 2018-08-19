
<p align="center">
  <h2 align="center">Docker machine Mac OS X Utils</h2>
  <p align="center">
    <a href="https://app.bitrise.io/app/108f6546a2dabcdd">
      <img src="https://app.bitrise.io/app/108f6546a2dabcdd/status.svg?token=FlpOj4XIGhpmVvJNIpfxOg&branch=master" alt="Build Status">
    </a>
    <a href="LICENSE.md">
      <img src="https://img.shields.io/badge/license-MIT-brightgreen.svg?style=flat-square" alt="Software License">
    </a>
    <a href="https://www.paypal.me/meabed">
      <img src="https://img.shields.io/badge/paypal-donate-179BD7.svg?style=flat-squares" alt="Donate">
    </a>
  </p>
</p>


## Introduction
> From [docs.docker.com](https://docs.docker.com/machine/get-started/)

> Docker for Mac uses HyperKit, a lightweight macOS virtualization solution built on top of the Hypervisor.framework.
> Currently, there is no docker-machine create driver for HyperKit, so use the virtualbox driver to create local machines
 

Working with docker on Mac OS X is frustrating, especially for large projects with a lot of folders and files.
Because docker does nor run natively on Mac OS, you get some problems with `docker-machine`, like **NFS Volume mounting, UTC time - ntp, file permissions**. 

During my last 6 years working with docker on Mac OS X, I have developed the script below tackles few of this issues and solve them.

## Solution
Several fixes on docker-machine for mac os x
- NFS Mount file permission mapping in `/etc/exports`
- Tweaked Mac OS X [nfsd](http://www.manpagez.com/man/5/nfs/) in `/etc/nfs.conf`
- Tweaked NFS Mount options for `docker-machine` `rw,noacl,nocto,noatime,nodiratime,soft,nolock,rsize=32768,wsize=32768,intr,tcp,nfsvers=3,actimeo=2`
- NFS Remount /Users/${USERNAME} dir for Mac OS X
- NTPD Update to UTC
- sysctl tweaks `vm.max_map_count=262144` `fs.file-max=801896` `net.core.somaxconn=65535`

## How to use

#### wget:
```bash
wget -O docker_machine_mount_nfs.sh https://raw.githubusercontent.com/me-io/docker-machine-mac-nfs-mount/master/docker_machine_mount_nfs.sh
# you can get machine name from docker-machine ls
sudo bash ./docker_machine_mount_nfs.sh default 
```

#### curl:
```bash
curl -o docker_machine_mount_nfs.sh https://raw.githubusercontent.com/me-io/docker-machine-mac-nfs-mount/master/docker_machine_mount_nfs.sh
# you can get machine name from docker-machine ls
sudo bash ./docker_machine_mount_nfs.sh default
```


## Contributing

Please feel free to contribute to this project! Pull requests and feature requests welcome! :v:

## License

The code is available under the [MIT license](LICENSE.md).
