
<p align="center">
  <h2 align="center">Docker machine Mac OS X NFS Util</h2>
  <p align="center">
    <a href="https://app.bitrise.io/app/108f6546a2dabcdd">
      <img src="https://app.bitrise.io/app/108f6546a2dabcdd/status.svg?token=FlpOj4XIGhpmVvJNIpfxOg&branch=master" alt="Build Status">
    </a>
    <a href="LICENSE.md">
      <img src="https://img.shields.io/badge/license-MIT-brightgreen.svg?style=flat-square" alt="Software License">
    </a>
    <a href="https://www.paypal.me/meabed">
      <img src="https://img.shields.io/badge/paypal-Buy_Me_Coffee-179BD7.svg?style=flat-squares" alt="Buy Me Coffee">
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
Several fixes on docker-machine for MacOS
- NFS Mount file permission mapping in `/etc/exports`
- Tweaked MacOS [nfsd](http://www.manpagez.com/man/5/nfs/) in `/etc/nfs.conf`
- Tweaked NFS Mount options for `docker-machine` `rw,noacl,nocto,noatime,nodiratime,soft,nolock,rsize=32768,wsize=32768,intr,tcp,nfsvers=3,actimeo=2`
- NFS Remount /Users/${USERNAME} dir for MacOS
- NTPD Update to UTC
- sysctl tweaks `vm.max_map_count=262144` `fs.file-max=801896` `net.core.somaxconn=65535`

### Changes

#### Mac OS nfs server nfsd `/etc/nfs.conf`:
```bash
# This option controls whether the NFS service is advertised via Bonjour.
# The default value is 1 (on).
nfs.server.bonjour = 0

# This option controls whether MOUNT requests for non-directory objects
# will be allowed.  The default value is 0 (off).
nfs.server.mount.regular_files = 1

# This option controls whether MOUNT requests are required to originate
# from a reserved port (port < 1024).  The default value is 1 (yes).
# Many NFS server implementations require this because of the false
# belief that this requirement increases security.
nfs.server.mount.require_resv_port = 0

# This option controls how many NFS server (nfsd) threads are made
# available to service NFS requests.  The default value is 8.
nfs.server.nfsd_threads = 9

# This option specifies that the NFS server should report unstable writes
# as stable writes.  The default is 0 (off).  While enabling this option
# can improve write performance, it will also put data integrity at risk
# because the NFS client will be told that data is on stable storage
# before it actually is.  The data may be lost if the NFS server crashes.
nfs.server.async = 1
```

#### NFS mounting client options from inside the docker-machine
```bash
# noacl: Disables Access Control List (ACL) processing.
noacl

# nocto: Suppress the retrieval of new attributes when creating a file
nocto

# noatime: Setting this value disables the NFS server from updating the inodes access time.
# As most applications do not necessarily need this value, you can safely disable this updating.
noatime

# nodiratime: Setting this value disables the NFS server from updating the directory access time. 
# This is the directory equivalent setting of noatime.
nodiratime

# Specify soft if the server is unreliable and you want to prevent systems from hanging when the server is down. When NFS tries to access a soft-mounted directory, 
# it gives up and returns an error message after trying retrans times (see the retrans option, later). 
# Any processes using the mounted directory will return errors if the server goes down.
soft

#nolock — Disables file locking. This setting is occasionally required when connecting to older NFS servers.
nolock

# rsize: The number of bytes NFS uses when reading files from an NFS server.
# The rsize is negotiated between the server and client to determine the largest block size that both can support. 
# The value specified by this option is the maximum size that could be used; however, the actual size used may be smaller. 
# Note: Setting this size to a value less than the largest supported block size will adversely affect performance.
rsize=32768

# wsize: The number of bytes NFS uses when writing files to an NFS server. 
# The wsize is negotiated between the server and client to determine the largest block size that both can support. 
# The value specified by this option is the maximum size that could be used; however, the actual size used may be smaller. 
# Note: Setting this size to a value less than the largest supported block size will adversely affect performance.
wsize=32768

# intr — Allows NFS requests to be interrupted if the server goes down or cannot be reached.
intr

# tcp — Specifies for the NFS mount to use the TCP protocol.
tcp

# Specifies which version of the NFS protocol to use
nfsvers=3

# attribute caches will time out in 1 seconds
actimeo=2

```
#### Sysctl options
```bash
# This file contains the maximum number of memory map areas a process may have.
# Memory map areas are used as a side-effect of calling malloc, 
# directly by mmap and mprotect, and also when loading shared libraries.
vm.max_map_count=262144

# Increase size of file handles and inode cache
fs.file-max=801896

# Increase number of incoming connections
net.core.somaxconn=65535
```
#### NTP settings
```bash
ntpd -p pool.ntp.org > /dev/null
```

#### putting it all together in bootlocal.sh which is file that execute every time docker-machine starts in the path `/var/lib/boot2docker/bootlocal.sh`
```
sudo sysctl -w vm.max_map_count=262144
sudo sysctl -w fs.file-max=801896
sudo sysctl -w net.core.somaxconn=65535
echo 'Un-mounting ${WKSDIR}'
sudo umount -f ${WKSDIR} 2> /dev/null
echo 'Starting docker-machine nfs-client'
sudo /usr/local/etc/init.d/nfs-client start 2> /dev/null
echo 'Mounting ${WKSDIR}'
sudo mkdir -p ${WKSDIR}
sudo mount -t nfs -o rw,noacl,nocto,noatime,nodiratime,soft,nolock,rsize=32768,wsize=32768,intr,tcp,nfsvers=3,actimeo=2 $B2D_NET:${WKSDIR} ${WKSDIR}
echo 'Mounted ${WKSDIR}'
sudo killall -9 ntpd
sudo ntpclient -s -h pool.ntp.org > /dev/null
sudo ntpd -p pool.ntp.org > /dev/null
echo docker-machine-date is: `date`

```

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
