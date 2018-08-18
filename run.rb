
SCRIPT_LINK = "https://raw.githubusercontent.com/me-io/docker-machine-mac-nfs-mount/master/docker_machine_mount_nfs.sh"
curl_flags = "fsSL"
system "/bin/bash -o pipefail -c '/usr/bin/curl -#{curl_flags} #{SCRIPT_LINK} | sudo /bin/bash -'"
