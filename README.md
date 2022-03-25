WIP update for etherpad for sandstorm. [List of WIP issues](ISSUES.md) (hopefully to move to Github issues).

NOTE: If you change the list of installed plugins, make sure to update the defaultPadText in settings.json

See the [changelog](.sandstorm/CHANGELOG.md).

# Raw packaging:

**WARNING: Don't do this on your normal computer**. It will install things, etc. This is intended for people who prefer raw spk because they run QubesOS or something like that, where you can make throwaway VMs in your own way. Most people likely should use the vagrant-spk option.

1) this repo needs to be checked out at /opt/app. Not as a symlink or anything like that, the real path has to be there. It affects how the app behaves at least in some ways. TODO (give known example).

2) your user should have write access (without requiring sudo) to /var/.

3) make sure your user isn't for some reason called "vagrant". A couple commands are vagrant-specific, and you may not want those commands to be run here.

## Build and run outside of Sandstorm

Building: run `sudo .sandstorm/setup.sh` and `.sandstorm/build.sh` manually.

Then run etherpad-lite once outside of sand Sandstorm to build the caching: run `.sandstorm/launcher.sh` manually.

## Run within Sandstorm

Run spk dev within .sandstorm/ to run it in Sandstorm.

# License
[Apache License v2](http://www.apache.org/licenses/LICENSE-2.0.html) for Etherpad
[Creative Commons Attribution-Sharealike 3.0](https://creativecommons.org/licenses/by-sa/3.0/) for the Etherpad logo (by Marcel Klehr) used for the app icon

## Attributions

Many of the Sandstorm-specific edits have been taken from Kenton's previous versions of:
* [Etherpad Lite Sandstorm App](https://github.com/kentonv/etherpad-lite).
* [`ep_author_neat`](https://github.com/kentonv/ep_author_neat).
* [`ep_comments_page`](https://github.com/kentonv/ep_comments).
