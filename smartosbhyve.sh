#!/bin/bash

#
# Produce a raw disk image suitable for use with SmartOS bhyve.  Will output an
# uncompressed raw disk image at, e.g.,
#
#     /rpool/images/output/smartosbhyve-omnios-stable.raw
#
# This tool requires "setup.sh" and "strap.sh" to have been run first.
#

set -o xtrace
set -o pipefail
set -o errexit

DATASET=rpool/images
MOUNTPOINT="$(zfs get -Ho value mountpoint "$DATASET")"
DISTRO=${DISTRO:-omnios}
BRANCH=${BRANCH:-stable}

TOP=$(cd "$(dirname "$0")" && pwd)

cd "$TOP"

pfexec "$TOP/image-builder/target/release/image-builder" \
    build \
    -T "$TOP/templates" \
    -d "$DATASET" \
    -g smartosbhyve \
    -n "$DISTRO-$BRANCH"

ls -lh "$MOUNTPOINT/output/smartosbhyve-$DISTRO-$BRANCH.raw"
