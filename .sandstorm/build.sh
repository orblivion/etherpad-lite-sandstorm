#!/bin/bash
set -euo pipefail

cd /opt/app

./scripts/checkout-repos
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

# Install basic plugins (from npm)
npm install $(cat ../basic-plugins)

../scripts/install-edited-plugins

# Etherpad tries to touch $plugin/.ep_initialized on first run,
# so let's symlink that to somewhere writable:
for plugin in $(cat ../basic-plugins; echo ep_author_neat; echo ep_comments_page); do
	ln -sf /var/plugins-initialized/$plugin node_modules/$plugin/.ep_initialized
done

cd ..
./scripts/install-capnp
