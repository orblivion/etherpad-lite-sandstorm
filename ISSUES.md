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

## Sandstorm profile name change does not affect name in existing documents

These are *not* a regression from the previous Etherpad app.

If you create a document and change your Sandstorm profile name after, the document will not adopt this new name.

But perhaps this is what we want? Etherpad has its own name change capability. If a Sandstorm user changes their name within Etherpad, we wouldn't want to overwrite it with their Sandstorm profile name after an app update with no warning.

Separately: if you post a comment and change your Etherpad name, the name on the comment will not change (though new comments will have your new name). This is likely not Sandstorm related. It makes sense if you look at the database. The database is one big key/value store, where each value is a json document. Each comment is one entry. Each comment entry (for some reason) contains both the user name and user id. Fixing this issue would require going through each comment and updating the username. (Perhaps this would be desired upstream, for that matter.)

# Figure Out

## Consider how to handle ep_initialized

`node_modules/ep_<pluginname>/.ep_initialized` seems to be created for each plugin whenever you first run etherpad-lite. For us, `node_modules` is part of the app directory, so our app can't write to it at run time. Our solution for now: during build, we create a symlink from `node_modules/ep_<pluginname>.ep_initialized` to `/var/sandstorm-plugins-initialized/ep_<pluginname>` (which is within the grain directory), so each grain first run can set these files.

Question: Why? I'm not sure what .ep_initialized does. Does this "initialization" happen within the app (i.e. `node_modules`) or within the grain (i.e. the database file)?

If the initialization happens in the app, we could just try to commit the final result to the spk including the `.ep_initialized` files and skip the symlinks.

If the initialization happens in the grain, what happens during upgrades to the plugins? Does anything need to be "reinitialized"? I.e. should we be wiping `/var/plugins-initalized` every app upgrade?

Neither option particularly makes sense to me. But it looks like in the previous version of the etherpad plugin, we did [the first of these two](https://github.com/ether/etherpad-lite/compare/9f51432175c55deb4da54075351dc870a0b35808...kentonv:sandstorm#diff-73c521a1bcbd7c52b7c1bb88c7be1dab29848b6c34e47823d13f57e43de93dc0R124):

## Socket Transport Protocols

In `settings.json`, I set a setting that I saw [set in the previous app](https://github.com/kentonv/etherpad-lite/commit/162c607f1adda7586bd12d2b7254fbeb2dac1c09):

```
-  "socketTransportProtocols" : ["xhr-polling", "jsonp-polling", "htmlfile"],
+  "socketTransportProtocols" : ["websocket"],
```

I'm not sure why it was done, but the app worked before and after the change.

# Improvements

## Comment notification links

This is not a regression.

It would be nice if clicking on a comment notification brought you to the specific comment.

Each comment has its own link with a hash URL. Opening the grain with the hash will start the grain with that comment open. I think these links are even sent to the Sandstorm notification API. But, clicking on the notification just sends you to the normal grain URL.

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

## Performance - Minification/Caching

## Performance - Loading Screen

There's somehting that happened after version 1.8.6 that made the "loading" screen come on and slow things down. I wonder if we can find out what it was and undo it. It was much faster without.

## Performance - Bypass Redirect

Kenton [tried to directly load the pad page](https://github.com/kentonv/etherpad-lite/commit/e5d0f0d4ac479d6edd92138a19aa2f50a9ceb794) rather than going through a redirct, but ran into issues.

But, perhaps there's a workaround. Then again, it's probably a small part of load time.

## Performance - Server Side

It seems that most of the load time happens on the server side before the "Loading" screen even comes up.

# Warnings

## Console log error - `ep_author_neat` - UNSETTLED FUNCTION BUG IN HOOK FUNCTION

For `acePostWriteDomLineHTML` and `aceEditEvent`

`aceEditEvent` warning goes away if you `return cb()` in the place where it is missing a return value. BUT - upstream doesn't even do this. Is this right? Dangerous? Etc.

`acePostWriteDomLineHTML` warning goes away if you `return cb()` at the end. However upstream it returns a timeout. Look into that.

## Console log error - require is not defined

I get this error, only on Sandstorm I think tho?
https://stackoverflow.com/questions/19059580/client-on-node-js-uncaught-referenceerror-require-is-not-defined

lib/ep_etherpad-lite/static/js/ace2_common.js?callback=require.define&v=8624a65e:1

is it related to any of the plugins? probly not.

## Check for any other browser console errors/warnings

## Check for any other sandstorm console errors/warnings

# Known Limitations

Stuff that will probably just stick around.

## Avatars will obscure 5-digit line numbers

We're (as of now) showing line numbers on the left (though this would be a change from the previous app version). Avatars are on the left as well, but further left. But, if you're crazy enough to have a 10,000+ line file, avatars will begin to obscure the left-most digits.

## PDF Export

In the previous app version, Kenton [tried to support pdf export](https://github.com/kentonv/etherpad-lite/commit/e67f2ec8a72476d7e9fa4f92caf7496cea00b87b) in the previous app version, but it made the spk massive and didn't work well.

But, perhaps there's a workaround if we really want this some day.

# QA

## Confirm that localizations work

## Confirm that removing ep_markdown won't break existing saved files

Is there such a thing as using ep_markdown creating changes in the file? If such a thing was saved, what would happen if opened in this new etherpad that doesn't have ep_markdown any longer?

## Deleting comments

Refreshing the page after.

I had a note about old comments still appearing. I don't remember exactly what it was, but maybe worth a quick look.

## Test on Mobile
