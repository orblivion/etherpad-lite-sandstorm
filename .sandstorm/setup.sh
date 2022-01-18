#!/bin/bash

# When you change this file, you must take manual action. Read this doc:
# - https://docs.sandstorm.io/en/latest/vagrant-spk/customizing/#setupsh

set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

echo "Installing the NodeSource Node.js 14.x repo..."

apt-get update
apt-get install -qq apt-transport-https

curl -sL https://deb.nodesource.com/setup_14.x | bash -

# Actually install node
apt-get install -qq nodejs git-core g++

# Capnp dependencies
apt-get install -qq libcapnp-dev

# Create a build directory to do npm installations. This is a workaround for a
# vagrant problem. See: https://github.com/sandstorm-io/vagrant-spk/issues/320
if [ $PWD == "/home/vagrant" ]
then
  mkdir -p /opt/build
  chmod o+wxr /opt/build
fi

exit 0
