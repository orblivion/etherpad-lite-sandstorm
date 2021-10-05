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

# Install plugins
npm install $(cat ../plugins)

# Etherpad tries to touch $plugin/.ep_initialized on first run,
# so let's symlink that to somewhere writable:
for plugin in $(cat ../plugins); do
	ln -sf /var/plugins-initialized/$plugin node_modules/$plugin/.ep_initialized
done


# Install capnp
#
# capnp is used for posting Sandstorm "activities"
#
# As of Oct 2021: The npm package is out of date. The node14 branch of the git
# repo is used on Sandstorm itself now. `npm install kenton/node-capnp#<ref>`
# does not work as of now, so we install the way we do.
#
# `npm install <something>` seems to delete anything it doesn't
# recognize. So we have to do our hack installations after all our proper npm
# installations.

# current tip of node14 branch. Using hash for reproducibility.
CAPNP_HASH=ca17e686f267e1fcce20a2ed9583847b4528cd8f

(cd node_modules && git clone https://github.com/kentonv/node-capnp.git capnp)
(cd node_modules/capnp && git checkout $CAPNP_HASH && npm install)
