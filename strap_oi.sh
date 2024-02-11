#!/bin/bash

#
# Use the Image Builder to produce a tar file that contains an installed
# OpenIndiana image.  The produced file should be something like:
#
#     /rpool/images/output/openindiana-hipster.tar
#
# This tool requires "setup.sh" to have been run first.
#

export DISTRO=${DISTRO:-openindiana}
export BRANCH=${BRANCH:-hipster}

TOP=$(cd "$(dirname "$0")" && pwd)

cd "$TOP"

#
# NOTE: See strap.sh for arguments that are also valid here.
#
./strap.sh "$@"
