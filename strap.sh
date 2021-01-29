#!/bin/bash

#
# Use the Image Builder to produce a tar file that contains an installed OmniOS
# image.  The produced file should be something like:
#
#     /rpool/images/output/omnios-bloody.tar.gz
#
# This tool requires "setup.sh" to have been run first.
#

set -o xtrace
set -o pipefail
set -o errexit

DATASET=rpool/images
MOUNTPOINT="$(zfs get -Ho value mountpoint "$DATASET")"
BRANCH=${BRANCH:-bloody}

TOP=$(cd "$(dirname "$0")" && pwd)

cd "$TOP"

for n in 01-strap 02-image 03-archive; do
	banner "$n"
	pfexec "$TOP/image-builder/target/release/image-builder" \
	    build \
	    -T "$TOP/templates" \
	    -d "$DATASET" \
	    -g omnios \
	    -n "$BRANCH-$n"
done

ls -lh "$MOUNTPOINT/output/omnios-$BRANCH.tar.gz"
