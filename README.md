# Tweakio Canister
Adds Canister API for Tweakio

## How does it work
This library gets installed to `/Library/TweakioPlugins` on rootful, `/var/jb/Library/TweakioPlugins` on rootless.

The library works by creating a new class that follows the structure of the `TWBaseApi` class that is defined in the Tweakio code, and changing the superclass to `TWBaseApi` during runtime.

# Contributing
Feel free to contribute by making a pull request

# Found an issue?
Please either file an issue here in the GitHub repo (I may not see it fast, which is why I suggest the second method more, which is:) or tell me the issue in the [Discord server](https://discord.gg/mZZhnRDGeg)

# Credits
* Thanks to everyone who has made/maintained [Canister API](https://github.com/cnstr)
* Thanks to my trusty beta testers
