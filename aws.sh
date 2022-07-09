#!/bin/bash

#
# Produce a raw disk image suitable for import into AWS for use in AMI
# creation.  Will output an uncompressed raw disk image at, e.g.,
#
#     /rpool/images/output/aws-omnios-bloody.raw
#
# This tool requires "setup.sh" and "strap.sh" to have been run first.
#

set -o xtrace
set -o pipefail
set -o errexit

TOP=$(cd "$(dirname "$0")" && pwd)
. "$TOP/lib/common.sh"

DISTRO=${DISTRO:-omnios}
BRANCH=${BRANCH:-bloody}

TOP=$(cd "$(dirname "$0")" && pwd)

cd "$TOP"

pfexec "$TOP/image-builder/target/debug/image-builder" \
    build \
    -T "$TOP/templates" \
    -d "$DATASET" \
    -g aws \
    -n "$DISTRO-$BRANCH"

ls -lh "$MOUNTPOINT/output/aws-$DISTRO-$BRANCH.raw"
