Consider a new MKVToolNix release, 99.0. Once I have the signed MKVToolNix source I would use it to create `MKVToolNix-99.0-1-arm64.dmg`, `MKVToolNix-99.0-1-x86_64.dmg` and so on. Any need for subsequent repackaging would mean me creating patches and/or scripts in this repo to address the issue and resulting in my making `MKVToolNix-99.0-2-arm64.dmg`, `MKVToolNix-99.0-2-x86_64.dmg` and so on available to the author.

This is the pattern that will repeat as new MKVToolNix releases become available.

Specifically, using release 99.0 as an example:

- A new release '99.0' of MKVToolNix is created, and a signed source release becomes available to me.

- Any packaging patches or scripts that were developed to repair the previous release that have been incorporated into the MKVToolNix are removed from this repo.

- macOS packages for the new release are created on each type of build machine (arm64 and x86_64) using `prep_to_build_mkvtoolnix_release.sh 99.0`, automatically creating revision 1 of each package. If the packages build without incident then:
    - The packages are uploaded to the MKVToolNix domain for download and further distribution (for example, via Homebrew)
    - The revision is 'published' on each build machine using `./publish_revision.sh 99.0`
    - I release a snapshot of the repo containing all patches and revisions for the release

- If, however, a Mac-specific build issue does arise with the release, I will endeavour to repair it with patches and scripts which I will include in this repo. (The release source itself will never be modified.) Once the packages build without incident then:
    - The packages are uploaded to MKVToolNix
    - The revision is 'published'
    - I release a snapshot of the repo
    - The repairs are fed back into MKVToolNix source via pull requests, ready for the next release

- If, over time, any Mac-specific build issues arise with the release before the next MKVToolNix release, I will endeavour to repair them with patches and scripts which I will include in this repo. Once the packages build without incident:
    - The packages are uploaded to MKVToolNix
    - The revision is 'published'
    - I release a snapshot of the repo
    - I raise pull requests in MKVToolNix for the repairs

- This last stage repeats until...

- A new MKVToolNix release is published, and the cycle starts again...