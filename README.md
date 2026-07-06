# package-mkvtoolnix-for-mac
This repo originally contained the artefacts I needed to package a notarized MKVToolNix GUI for Apple silicon on a fresh install of macOS. It has since grown to enable me to create packages for Apple silicon, Intel and universal binary MKVToolNix releases.

The script and patches in this repo are the only elements that can be attributed to [me](mailto:touchstone64@gweb.me.uk). The MKVToolNix GUI and associated tools are created and owned by Moritz Bunkus and are thoroughly [documented here](https://mkvtoolnix.download/index.html).

These artefacts have been used to package notarized releases of the MKVToolNix GUI as described below:

| repo | MVKToolNix GUI | DMG revision | Built on macOS | Apple silicon | Intel | Universal |
|:----:|:--------------:|:-----:|:-----:|:----------:|:----------:|:----------:|
| 1.4  | 99.0 |1| 26.5   | [download](https://mkvtoolnix.download/macos/releases/99.0/MKVToolNix-99.0-1-arm64.dmg) ([sha-512](https://mkvtoolnix.download/macos/releases/99.0/MKVToolNix-99.0-1-arm64.dmg.sha512)) | - | [download](https://mkvtoolnix.download/macos/releases/99.0/MKVToolNix-99.0-1-universal.dmg) ([sha-512](https://mkvtoolnix.download/macos/releases/99.0/MKVToolNix-99.0-1-universal.dmg.sha512)) |
|      |      |1| 15.7.7 | - | [download](https://mkvtoolnix.download/macos/releases/99.0/MKVToolNix-99.0-1-x86_64.dmg) ([sha-512](https://mkvtoolnix.download/macos/releases/99.0/MKVToolNix-99.0-1-x86_64.dmg.sha512)) | [download](https://mkvtoolnix.download/macos/releases/99.0/MKVToolNix-99.0-1-universal.dmg) ([sha-512](https://mkvtoolnix.download/macos/releases/99.0/MKVToolNix-99.0-1-universal.dmg.sha512)) |
| 1.3  | 98.0 |1| 26.5   | [download](https://mkvtoolnix.download/macos/releases/98.0/MKVToolNix-98.0-1-arm64.dmg) ([sha-512](https://mkvtoolnix.download/macos/releases/98.0/MKVToolNix-98.0-1-arm64.dmg.sha512)) | - | [download](https://mkvtoolnix.download/macos/releases/98.0/MKVToolNix-98.0-1-universal.dmg) ([sha-512](https://mkvtoolnix.download/macos/releases/98.0/MKVToolNix-98.0-1-universal.dmg.sha512)) |
|      |      |1| 15.7.7 | - | [download](https://mkvtoolnix.download/macos/releases/98.0/MKVToolNix-98.0-1-x86_64.dmg) ([sha-512](https://mkvtoolnix.download/macos/releases/98.0/MKVToolNix-98.0-1-x86_64.dmg.sha512)) | [download](https://mkvtoolnix.download/macos/releases/98.0/MKVToolNix-98.0-1-universal.dmg) ([sha-512](https://mkvtoolnix.download/macos/releases/98.0/MKVToolNix-98.0-1-universal.dmg.sha512)) |
| 1.2  | 98.0 || 26.4.1  | [download](https://www.gweb.me.uk/dmg/arm64-mkvtoolnix-gui/1.2/MKVToolNix-98.0.dmg) | n/a | none |
| 1.1  | 98.0 || 26.4.1  | [download](https://www.gweb.me.uk/dmg/arm64-mkvtoolnix-gui/1.1/MKVToolNix-98.0.dmg) | n/a | none |
| 1.0  | 98.0 || 26.4.1  | (deprecated) | - | - |
| 0.1  | 98.0 || 26.4.1  | (deprecated) | - | - |

## Strategy

In the initial releases (0.1-1.2) of the repo, modifications to MKVToolNix build and configuration scripts were applied as patches to the source to achieve automated notarization and other features. Each release of the repo repackaged MKVToolNix 98.0, without affecting the upstream source.

This technique worked well and those packaging modifications have since been incorporated into the upstream source, ready to be part of MKVToolNix's packaging. (The changes can be reviewed in `NEWS.md` included in each MKVToolNix release.) The patches in this repo mean that existing releases can also be repackaged with those same enhancements.

In repo 1.3 and later, one obvious change is that DMG package file names include the machine type (arm64 or x86_64) that they target. So, an MKVToolNix 98.0 package built on an Intel Mac, which used to be named `MKVToolNix-98.0.dmg`, will now be named `MKVToolNix-98.0-x86_64.dmg`.

Ideally this repo would be a benign packaging layer automating the creation of notarized Apple silicon (arm64) and Intel (x86_64) MKVToolNix releases from signed releases of MKVToolNix source. However, the main lesson learned during the development of the initial repo releases was that changes beyond my control -- such as third-party libraries being deprecated, or being broken by a macOS release -- meant that I need to be able to repackage an MKVToolNix release without changing the release itself.

Consequently, in repo 1.3 and later, macOS packaging has been enhanced to add a 'DMG revision' to the DMG package name. So, if a release needs to be repackaged to support a new version of macOS, for example, that revision would be incremented.

Consider a new MKVToolNix release, 99.0. Once I have the signed MKVToolNix source I would use it to create `MKVToolNix-99.0-1-arm64.dmg`, `MKVToolNix-99.0-1-x86_64.dmg` and so on. Any need for subsequent repackaging would mean me creating patches and/or scripts in this repo to address the issue and resulting in my making `MKVToolNix-99.0-2-arm64.dmg`, `MKVToolNix-99.0-2-x86_64.dmg` and so on available to the author.

This is the pattern that will repeat as new MKVToolNix releases become available.

Specifically, using release 99.0 as an example:

- A new release '99.0' of MKVToolNix is created, and a signed source release becomes available to me.

- Any packaging patches or scripts that were developed to repair the previous release, that have since been incorporated into MKVToolNix's packaging, are removed from this repo.

- macOS packages for the new release are created on each type of build machine (arm64 and x86_64) using `prep_to_build_mkvtoolnix_release.sh 99.0`, automatically creating revision 1 of each package. If the packages build without incident then:
    - The packages are uploaded to the MKVToolNix domain for download and further distribution (for example, via Homebrew)
    - The revision is 'published' on each build machine using `./publish_revision.sh 99.0`
    - I release a snapshot of the repo containing all patches and revisions for the release

- If, however, a Mac-specific build issue does arise with the release, I will endeavour to repair it with patches and scripts which I will include in this repo. (The release source itself will never be modified.) Once the packages build without incident then:
    - The packages are uploaded to MKVToolNix
    - The revision is 'published'
    - I release a snapshot of the repo
    - The repairs are fed back into MKVToolNix's packaging via pull requests, ready for the next release

- If, over time, any Mac-specific build issues arise with the release before the next MKVToolNix release, I will endeavour to repair them with patches and scripts which I will include in this repo. Once the packages build without incident:
    - The packages are uploaded to MKVToolNix
    - The revision is 'published'
    - I release a snapshot of the repo
    - I raise pull requests in MKVToolNix for the repairs

- This last stage repeats until...

- A new MKVToolNix release is published, and the cycle starts again...

If you do find a Mac-specific build issue with a release please [create an issue](https://github.com/Touchstone64/release-arm64-mkvtoolnix-gui/issues/new/) so I can help resolve it.

# Preparing for packaging on a fresh installation of macOS

The rest of this README.md file is essentially a record of the steps taken to build, sign and notarize an MVKToolNix GUI disk image ready for installation on macOS.

## Export a code-signing certificate
On a Mac used to sign macOS applications, open Keychain Access and in the login keychain, click My Certificates and export your Developer ID Application certificate using 'File | Export Items' and select the file format 'Personal Information Exchange (.p12)'.

Provide a password and save the exported certificates. You'll use this export to re-use your working code-signing certificate in another macOS installation.

(You may of course prefer to create a Developer ID Application certificate signing request on the fresh macOS installation. This export process is the just the method I chose to use.)

## Create a fresh macOS Install
Create a new APFS volume on your chosen internal or external drive and use the 'Install macOS Tahoe' app to install macOS. The app can be downloaded from the App Store. A virtual machine (VM) can't be used because they don't support App Store installs, which is required to get Xcode.

## Configure macOS
Run through the installation of macOS, these are my preferences:

- Set up as a new user to avoid environment pollution
- For Apple Account: sign in later in Settings
- Enable Location Services, Touch ID etc., as desired
- Click 'Get Started' to ... get started
- Configure trackpad, keyboard as desired
- Rename Mac as desired

Enable iCloud and any other macOS features as desired. Since this is an instance intended for a clean, from-source signed build I prefer to keep it as light as possible.

The text 'your terminal' below refers to your chosen terminal emulator, be it the macOS Terminal app, [iTerm2](https://iterm2.com) or whatever your personal preference. If it's not macOS Terminal then install it now.

## Setup build pre-requisites on macOS

- Sign in to the Apple Developer site with your Apple account to download and install Xcode (for Sequoia, you'll need Xcode 26.0.1).
- Run Xcode and accept the license agreements.
- In your terminal, run `xcode-select --install` to install the command-line developer tools.
- In your terminal, use `xcode-select -p` to check the location of the developer directory, it should be '/Applications/Xcode.app/Contents/Developer'.

## Setup code-signing prerequisites on macOS
- If you exported a working code-signing certificate above, open Keychain Access and use 'File | Import Items' to import the .p12 certificates file. (You may need to move one or more imported intermediate certificates to the System keychain.)
- If you chose to create a new Developer ID Application certificate, install it using Keychain Access.
- In Keychain Access, select My Certificates in the login keychain and inspect your 'Developer ID Application' certificate to ensure it's trusted.
- In your terminal, run `security find-identity -p codesigning` to review the code-signing identities now recognised by the OS to ensure your certificate is installed as expected.

## Setup notarization prerequisites on macOS
App notarization is getting easier. If you're just getting started, at the time of writing [this site](https://www.technotes.omnis.net/Technical%20Notes/Deployment/macOS%20notarization/index.html) is a helpful resource to guide you through the steps.

To set up notarization you'll need your Apple developer account email address, an app-specific password and your team ID. (If you're not sure about any of these, review the site linked above.)

- In your terminal, use `xcrun notarytool store-credentials --apple-id "<YOUR-APPLE-ID-EMAIL>" --password "<YOUR_APP-SPECIFIC-PASSWORD>" --team-id "<YOUR-TEAM-ID>"` to create your notary profile in the default keychain. When prompted, provide your notary profile name (for example, 'MyNotaryProfile').

Your credentials will be validated and saved to the default keychain.

## Prepare your release build

Using release 98.0 as an example, in your terminal:

- Choose or create a working directory for this project and change to it
- Clone this repo using `git clone https://github.com/Touchstone64/package-mkvtoolnix-for-mac`
- Use `cd ./package-mkvtoolnix-for-mac` to change to the repo directory
- Edit `./prep_to_build_mkvtoolnix_release.sh` and search for 'config.local.sh'
- Change the value of `SIGNATURE_IDENTITY` to be your Developer ID Application certificate identity
- If you want to notarize the release, change the value of `NOTARY_PROFILE` to be the name of the notary profile in your keychain (set up above). If not, remove the line from the script.
- Save the file and run `./prep_to_build_mkvtoolnix_release.sh 98.0` to prepare to build and sign release 98.0

## Build the disk image

Using release 98.0 as an example, in your terminal:

- Use `cd ./release-98.0/packaging/macos` to change to the release's macos packaging directory
- Run `./build.sh` to build all of the component parts of the MKVToolNix GUI. This will take some time.
- Run `./build.sh dmg` to assemble, sign and (optionally) notarize the disk image for the release

By default the build script uses ~/opt and ~/tmp to build and assemble all the component parts needed to create the MKVToolNix GUI from source.

The signed and (optionally) notarized disk image will be located at ~/tmp/compile/MKVToolNix-98.0-r-arm64.dmg or MKVToolNix-98.0-r-x86_64.dmg (depending on your Mac's CPU type) where `r` is the DMG revision.