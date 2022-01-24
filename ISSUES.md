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

This is a regression

## Font size not preserved from previous Etherpad Sandstorm app

Seems to be not Sandstorm specific, should confirm with totally fresh Etherpad. Of course should check with latest Etherpad.

# Figure Out

## Consider how to handle ep_initialized

node_modules/ep_<pluginname>/.ep_initialized seems to be created whenever you first run etherpad-lite with a given plugin. node_modules directory is part of the app directory, so our app can't write to it. Instead, we set it as a symlink to /var/plugins-initialized (within the grain directory), so each run can set these files.

Question: Why? I'm not sure what .ep_initialized does. Does etherpad change the plugin inside node_modules in any other way?

If not, why can we not just write the files during build time to pretend the plugins have been initialized?

What happens when etherpad upgrades? Will we need to emulate that, whatever it is, when we upgrade going forward? If we keep the current symlink system, should we be wiping /var/plugins-initialized for every upgrade?

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
* Have instructions for upgrading packages (security, etc) and re-saving package-lock

## npm audit

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

I have a change to set SESSIONKEY.txt at /var/SESSIONKEY.txt explicitly. However I realized later that this may already be fixed by the symlink within rootfs.

We should remove one fix or the other.

# Known Limitations

Stuff that will probably just stick around.

## Avatars will obscure 5-digit line numbers

Assuming you're crazy enough to make such a long file.

# QA

## Confirm that localizations work

## Confirm that removing ep_markdown won't break existing saved files

Is there such a thing as using ep_markdown creating changes in the file? If such a thing was saved, what would happen if opened in this new etherpad that doesn't have ep_markdown any longer?

## Deleting comments

Refreshing the page after.

I had a note about old comments still appearing. I don't remember exactly what it was, but maybe worth a quick look.
