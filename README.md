#### docker-machine-mac-nfs-mount

Docker machine ntpd
sysctl
Starting nfs-client

nfs.server.bonjour = 0
nfs.server.mount.regular_files = 1
nfs.server.mount.require_resv_port = 0
nfs.server.nfsd_threads = 9
nfs.server.async = 1

sudo mount -t nfs -o rw,noacl,nocto,noatime,nodiratime,soft,nolock,rsize=32768,wsize=32768,intr,tcp,nfsvers=3,actimeo=2 $B2D_NET:${WKSDIR} ${WKSDIR}

https://docs.docker.com/toolbox/overview/
