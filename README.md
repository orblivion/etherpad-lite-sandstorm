WIP update for etherpad for sandstorm.

NOTE: If you change the list of installed plugins, make sure to update the defaultPadText in settings.json

Much of this will have been taken from [Kenton's previous version](https://github.com/kentonv/etherpad-lite).

# Raw packaging:

**WARNING: Don't do this on your normal computer**. It will install things, etc. This is intended for people who prefer raw spk because they run QubesOS or something like that, where you can make throwaway VMs in your own way. Most people likely should use the vagrant-spk option.

Firstly, this repo needs to be checked out at /opt/app. Not as a symlink or anything like that, the real path has to be there. It affects how the app behaves at least in some ways. TODO (give known example).

Secondly, your user should have write access (without requiring sudo) to /var/.

## Build and run outside of Sandstorm

Building: run `sudo .sandstorm/setup.sh` and `.sandstorm/build.sh` manually.

Then run etherpad-lite once outside of sand Sandstorm to build the caching: run `.sandstorm/launcher.sh` manually.

## Run within Sandstorm

Run spk dev within .sandstorm/ to run it in Sandstorm.
