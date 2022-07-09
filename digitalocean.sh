#!/bin/bash

#
# Produce a raw disk image suitable for import into DigitalOcean for custom
# image creation.  Will output an uncompressed raw disk image at, e.g.,
#
#     /rpool/images/output/digitalocean-omnios-bloody.raw
#
# This tool requires "setup.sh" and "strap.sh" to have been run first.
#

set -o xtrace
set -o pipefail
set -o errexit

TOP=$(cd "$(dirname "$0")" && pwd)
. "$TOP/lib/common.sh"

BRANCH=${BRANCH:-bloody}

TOP=$(cd "$(dirname "$0")" && pwd)

cd "$TOP"

pfexec "$TOP/image-builder/target/debug/image-builder" \
    build \
    -T "$TOP/templates" \
    -d "$DATASET" \
    -g digitalocean \
    -n "omnios-$BRANCH"

ls -lh "$MOUNTPOINT/output/digitalocean-omnios-$BRANCH.raw"
