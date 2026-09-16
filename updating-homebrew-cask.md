
NOTE (16th September 2026): The Homebrew team suggest that their autobump feature will automate simple version bumps for supported casks, every 3 hours or so. I'll test this on the next release; the suggestions in this document may only be needed for major changes to the mkvtoolnix-app cask.

Update [my fork](https://github.com/Touchstone64/homebrew-cask) of the homebrew/cask [repo](https://github.com/Homebrew/homebrew-cask).

Download a local copy of the repo using `brew tap --force homebrew/cask`.

Change to the repo's directory using `cd "$(brew --repository homebrew/cask)"`. (Also updated ruby using `mise install 4.0.6` as it was reported missing when changing to the cask directory).

Add the fork as a remote using `git remote add Touchstone64 https://github.com/Touchstone64/homebrew-cask.git`.

`git checkout main` ('Your branch is up to date with 'origin/main'), `brew update` ('Already up-to-date') and create a branch (`git checkout -b mkvtoolnix-app-101.0 origin/HEAD`).

Update `./Casks/m/mkvtoolnix-app.rb` with version numbers, SHA codes etc.

Test the updated cask using:
1. `HOMEBREW_NO_INSTALL_FROM_API=1 brew install --cask mkvtoolnix-app`,

1. `brew uninstall --cask mkvtoolnix-app`, and 

1. `brew lgtm --online` (weird livecheck errors in audit).

Commit change using message `mkvtoolnix-app 101.0` (for example) but DO NOT try to submit/push to 'main'. Instead upload the commit to the fork using `git push --set-upstream Touchstone64 mkvtoolnix-app-101.0`.

Go to the [fork repo](https://github.com/Touchstone64/homebrew-cask) and create a pull request 👍

Once merged, delete branch and `brew untap --force homebrew/cask`