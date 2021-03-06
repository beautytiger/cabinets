#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

DIR=$(cd $(dirname "${BASH_SOURCE[0]}") >/dev/null 2>&1 && pwd)
cd $DIR

DOCKER_VERSION='19.03.14'
CENTOS_VERSION='7.9.2009'

OS_BASED_PATH="${CENTOS_VERSION}/${DOCKER_VERSION}"
cd ${OS_BASED_PATH}

echo "installing docker"

docker version >/dev/null 2>&1 && echo "docker already installed" && exit 0

rpm -iUvh system-rpm/*.rpm --nodeps --force
rpm -iUvh docker/*.rpm --nodeps --force

mkdir -p /etc/docker
mkdir -p /etc/systemd/system/docker.service.d

cat >/etc/docker/daemon.json <<EOF
{
  "insecure-registries": ["0.0.0.0/0"],
  "exec-opts": ["native.cgroupdriver=systemd"],
  "storage-driver": "overlay2",
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m",
    "max-file": "3"
  },
  "storage-opts": [
    "overlay2.override_kernel_check=true"
  ]
}
EOF

systemctl enable docker --now
systemctl status docker | grep 'active (running)'
docker info | grep 'Native Overlay Diff: true'
