WIP update for etherpad for sandstorm.

# Raw packaging:

**WARNING: Don't do this on your normal computer**. It will install things, etc. This is intended for people who prefer raw spk because they run QubesOS or something like that, where you can make throwaway VMs in your own way. Most people likely should use the vagrant-spk option.

Firstly, this repo needs to be checked out at /opt/app. Not as a symlink or anything like that, the real path has to be there. It affects how the app behaves at least in some ways. TODO (give known example).

Run `sudo .sandstorm/setup.sh` and `.sandstorm/build.sh` manually.

Run spk dev within .sandstorm/ to run it.
