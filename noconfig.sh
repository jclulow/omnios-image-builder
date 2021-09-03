#!/bin/bash

#
# Produce a raw disk image that does not include the metadata agent and has a
# blank root password for console login.  Will output an uncompressed raw disk
# image at, e.g.,
#
#     /rpool/images/output/noconfig-ttya-openindiana-hipster.raw
#
# This tool requires "setup.sh" and "strap_oi.sh" to have been run first.
#

set -o xtrace
set -o pipefail
set -o errexit

DATASET=rpool/images
MOUNTPOINT="$(zfs get -Ho value mountpoint "$DATASET")"
DISTRO=${DISTRO:-openindiana}
BRANCH=${BRANCH:-hipster}
CONSOLE=${CONSOLE:-ttya}

TOP=$(cd "$(dirname "$0")" && pwd)

cd "$TOP"

pfexec "$TOP/image-builder/target/debug/image-builder" \
    build \
    -T "$TOP/templates" \
    -d "$DATASET" \
    -g noconfig \
    -n "$CONSOLE-$DISTRO-$BRANCH"

ls -lh "$MOUNTPOINT/output/noconfig-$CONSOLE-$DISTRO-$BRANCH.raw"
