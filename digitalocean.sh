#!/bin/bash

#
# Produce a raw disk image suitable for import into DigitalOcean for custom
# image creation.  Will output an uncompressed raw disk image at, e.g.,
#
#     /rpool/images/output/digitalocean-omnios-stable-r151046.raw
#
# This tool requires "setup.sh" and "strap.sh" to have been run first.
#

set -o xtrace
set -o pipefail
set -o errexit

TOP=$(cd "$(dirname "$0")" && pwd)
. "$TOP/lib/common.sh"

DISTRO=${DISTRO:-omnios}
BRANCH=${BRANCH:-stable}
RELEASE=${RELEASE:-151046}

TOP=$(cd "$(dirname "$0")" && pwd)

cd "$TOP"

pfexec "$TOP/image-builder/target/debug/image-builder" \
    build \
    -T "$TOP/templates" \
    -d "$DATASET" \
    -g digitalocean \
    -F "release=$RELEASE" \
    -n "$DISTRO-$BRANCH" \
    -N "$DISTRO-$BRANCH-r$RELEASE"

ls -lh "$MOUNTPOINT/output/digitalocean-$DISTRO-$BRANCH-r$RELEASE.raw"
