#!/bin/bash
set -euo pipefail

cd /opt/app

./scripts/checkout-etherpad
./scripts/apply-patches

export NODE_ENV=production

cd etherpad-lite

# TODO we could rely on package-lock.json for reproducibility. Though for
# security we should make it easy to upgrade and update package-lock.json.

./bin/installDeps.sh

# sqlite is an optional dependency that must be installed seperately. For some
# reason it is also missing this build dependency:
npm install @mapbox/node-pre-gyp
npm install sqlite3

#Install capnp
# capnp is used for posting Sandstorm "activities"
# The npm package as of Oct 2021 is two years old, and node14 seems to have
# been implemented a month ago.
# TODO - Ask Kenton to publish node14 branch on npm?

# current tip of node14 branch. Using hash for reproducibility.
CAPNP_HASH=ca17e686f267e1fcce20a2ed9583847b4528cd8f

# Using hack from Kenton's Etherpad package, since building from git repo with
# npm somehow breaks while this does not
(cd node_modules && git clone https://github.com/kentonv/node-capnp.git capnp)
(cd node_modules/capnp && git checkout $CAPNP_HASH && npm install)

# Install plugins
npm install $(cat ../plugins)

# Etherpad tries to touch $plugin/.ep_initialized on first run,
# so let's symlink that to somewhere writable:
for plugin in $(cat ../plugins); do
	ln -sf /var/plugins-initialized/$plugin node_modules/$plugin/.ep_initialized
done
