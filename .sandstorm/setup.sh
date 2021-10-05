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

exit 0
