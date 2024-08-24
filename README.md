# full bit development (fbd) packages

This repo is designed to hold packages created byt the full bit development team.
It currently comprised of some shell scripts, but in the future this can be developed as a 
go binary that's self contained.

Running the `./fdb-gh-packages.sh` script will packag all the binaries in the `gh-projects.url`
file into their own packages and make them available at the root of the working directory.

NOTICE: by the nature of shell scripts, this repository is quite sensitive to breakage. If it breaks,
you get to keep all the pieces. I provide no garantees over this repo.

## Future work

[ ] development of self contained go binary
[ ] setup public apt repository to host the packages
[ ] setup public rpm repository to host the packages
