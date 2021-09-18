#!/bin/bash
set -euo pipefail

cd /opt/app

./scripts/checkout-etherpad
./scripts/apply-patches

export NODE_ENV=production

cd etherpad-lite

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
