#!/bin/bash
set -euo pipefail

# /opt/app should always be mounted for the synced folder, so we have to check
# for signs of /opt/build/app to see if the bind mount is active
if (findmnt | grep \/opt\/build\/app );
then
  echo ""
  echo "Looks like we never unmounted /opt/build/app from a previous run. This"
  echo "probably means that we are running this script from within the mounted"
  echo "directory, not the original /opt/app. For safety and simplicity, we are just"
  echo "going to exit."
  echo ""
  echo "The simplest fix is to restart the VM. If you decide to ssh in to unmount it"
  echo "manually, be careful not to unmount it too many times, since /opt/app is"
  echo "supposed to be mounted as a synced folder."
  echo ""

  # I tried just unmounting here, but /opt/app is busy, perhaps from running
  # this very script.

  exit 1
fi

# In Vagrant, /opt/app is a synced_folder. This causes a problem for npm
# install. See: https://github.com/sandstorm-io/vagrant-spk/issues/320
#
# The workaround here is to copy /opt/app over to a directory that is not
# within a synced folder, namely /opt/build/app. Then we can build there and
# copy the results back to /opt/app.
#
# However that creates a new issue. npm installation generates some files
# that include references to other files as abolute paths. We prefer that
# those paths end up based on /opt/app rather than /opt/build/app, since that's
# where the built files will be moved to.
#
# Our solution is to do a "bind mount". This will re-mount /opt/build/app as
# /opt/app. The original synced folder /opt/app is hidden for the moment. We
# can now build in /opt/app, and the results will also appear under
# /opt/build/app. After building, we unmount, bringing the original /opt/app
# back. We then copy the results from /opt/build/app to /opt/app.
#
# https://unix.stackexchange.com/questions/198590/what-is-a-bind-mount
#
# For copying over the results, we could just copy and delete all of
# etherpad-lite, but I'm a little worried that it could disrupt a developer
# inside that directory. I am opting for copying specific things and confirming
# nothing was missed (see below). (wiping and overwriting node_modules as we do
# here is sketchy enough, but I think npm might do this anyway).
#
# Finally, we only want to do this for vagrant-spk, not spk. Firstly, we don't
# need it for spk. Secondly, while it could work just fine for spk in
# principle, I'm worried about an edge case. Supposing there's a crash in the
# middle of build.sh. It could leave /opt/app as the bind mount directory,
# containing the same contents as the original /opt/app. The developer might
# not realize this, and might end up getting tripped up, perhaps losing work
# inadvertently, etc. This isn't such a danger with vagrant-spk, because the
# bind mount happens within the VM. The working directory is always in the host
# OS and is not hidden by the bind mount in the VM.

# This is the original /opt/app
cd /opt/app

# Set up these repositories before the bind mount. We want them to be visible
# to the working directory.
./scripts/checkout-repos
./scripts/apply-patches

# Do the bind mount if we're in vagrant.
if [ $USER == "vagrant" ]
then
  rm -rf /opt/build/app
  cp -r /opt/app /opt/build/app

  sudo mount --bind /opt/build/app /opt/app
fi

# For vagrant, this is now within the bind mounted /opt/app
cd /opt/app/etherpad-lite

export NODE_ENV=production

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

# This is only so that the diff below doesn't complain about nonexistent files.
# /var/ is per-grain when we run, so this shouldn't have an effect on it.
sudo mkdir -p /var/sandstorm-plugins-initialized
sudo chmod o+xwr /var/sandstorm-plugins-initialized

# Etherpad tries to touch $plugin/.ep_initialized on first run,
# so let's symlink that to somewhere writable:
for plugin in $(cat ../basic-plugins; echo ep_author_neat; echo ep_comments_page); do
	ln -sf /var/sandstorm-plugins-initialized/$plugin node_modules/$plugin/.ep_initialized

	# Only so that the diff below doesn't complain about nonexistent files. /var/
	# is per-grain when we run.
	touch /var/sandstorm-plugins-initialized/$plugin
done

cd ..
./scripts/install-capnp

# Undo the bind mount now if we're in vagrant, and copy our built directories over.
if [ $USER == "vagrant" ]
then
  cd /opt # get out of /opt/app so we can unmount
  sudo umount /opt/app

  # Copy the sepecific things we expect to change during the build, and confirm
  # we didn't miss anything with a diff below.
  rm -rf /opt/app/etherpad-lite/node_modules
  cp -r /opt/build/app/etherpad-lite/node_modules /opt/app/etherpad-lite/
  rm -rf /opt/app/etherpad-lite/src/node_modules
  cp -r /opt/build/app/etherpad-lite/src/node_modules /opt/app/etherpad-lite/src/
  cp /opt/build/app/etherpad-lite/package-lock.json /opt/app/etherpad-lite/package-lock.json

  # 1) Make sure the funny business with vagrant synced folders doesn't lead it
  #   to copy over node_modules incompletely.
  # 2) The build scripts above are controlled by etherpad. If they generate
  #   something other than node_modules, I don't want to miss it.
  diff -r /opt/build/app/etherpad-lite /opt/app/etherpad-lite || (
    echo "Seems like something other than node_modules was built during install.";
    echo "build.sh should be updated to transfer these over to /opt/app";
    exit 1;
  )
fi

# Another thing to offload startup time onto build time
cd /opt/app/etherpad-lite
mkdir -p cache # TODO - no longer need to do this in the etherpad-lite startup script
node ./src/node/cachePluginDependenciesObj.js
