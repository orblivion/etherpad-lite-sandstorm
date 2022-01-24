# Bugs

## App Doesn't work for newer firefox

See this comment, and followup discussion:

https://github.com/sandstormports/community-project/issues/15#issuecomment-1017807955

## "Delete Comment" button missing for users with comment-only permission

(this is a regression)

## Pasting large amounts of multi-line text does not work

It seems to crash the server.

* Not sure if it's Sandstorm-only
* Not sure if latest Etherpad (1.8.16) fixes it.
* This is a regression from our previous app

## Font size not preserved in documents created with previous Etherpad Sandstorm app

This can be seen by trying to open the included sqlite3 file in the `test/` directory. Font size 8 and Font size 20 show up the same.

This seems to be not Sandstorm specific, but need to confirm with totally fresh Etherpad install. We should also check with latest Etherpad version.

# Figure Out

## Consider how to handle ep_initialized

`node_modules/ep_<pluginname>/.ep_initialized` seems to be created for each plugin whenever you first run etherpad-lite. For us, `node_modules` is part of the app directory, so our app can't write to it at run time. Our solution for now: during build, we create a symlink from `node_modules/ep_<pluginname>.ep_initialized` to `/var/plugins-initialized/ep_<pluginname>` (which is within the grain directory), so each grain first run can set these files.

Question: Why? I'm not sure what .ep_initialized does. Does this "initialization" happen within the app (i.e. `node_modules`) or within the grain (i.e. the database file)?

If the initialization happens in the app, we could just try to commit the final result to the spk including the `.ep_initialized` files and skip the symlinks.

If the initialization happens in the grain, what happens during upgrades to the plugins? Does anything need to be "reinitialized"? I.e. should we be wiping `/var/plugins-initalized` every app upgrade?

Neither option particularly makes sense to me.

# Improvements

## NODE_ENV=production

NODE_ENV=production runs faster and more secure apparently.

## Use package-lock.json

Use package-lock.json

* So we don't get left-padded.
* More consistent to debug

Though:

* Etherpad seems to have it under version control and also in .gitignore. So I'm not sure whether we are already covered.
* Make sure to consider both etherpad-lite/node_modules and etherpad-lite/src/node_modules
* Have instructions for upgrading packages (security, etc) and re-saving package-lock, unless Etherpad project itself is generally on top of this

## npm audit

Assuming Etherpad isn't already on top of this. Though, we may not be packaging the very latest version of Etherpad every time (including this time).

# Warnings

## Check for any other browser console errors/warnings

## Check for any other sandstorm console errors/warnings

## Console log error - require is not defined

I get this error, only on Sandstorm I think tho?
https://stackoverflow.com/questions/19059580/client-on-node-js-uncaught-referenceerror-require-is-not-defined

lib/ep_etherpad-lite/static/js/ace2_common.js?callback=require.define&v=8624a65e:1

is it related to any of the plugins? probly not.

# Cleanups

## SESSIONKEY path

I have a patch to save SESSIONKEY.txt to /var/SESSIONKEY.txt explicitly. However, I realized later that this may already be covered by the symlink within rootfs.

We should remove one fix or the other.

# Known Limitations

Stuff that will probably just stick around.

## Avatars will obscure 5-digit line numbers

We're (as of now) showing line numbers on the left (though this would be a change from the previous app version). Avatars are on the left as well, but further left. But, if you're crazy enough to have a 10,000+ line file, avatars will begin to obscure the left-most digits.

# QA

## Confirm that localizations work

## Confirm that removing ep_markdown won't break existing saved files

Is there such a thing as using ep_markdown creating changes in the file? If such a thing was saved, what would happen if opened in this new etherpad that doesn't have ep_markdown any longer?

## Deleting comments

Refreshing the page after.

I had a note about old comments still appearing. I don't remember exactly what it was, but maybe worth a quick look.
