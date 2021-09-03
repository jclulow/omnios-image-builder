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
DISTRO=${DISTRO:-omnios}
BRANCH=${BRANCH:-bloody}

TOP=$(cd "$(dirname "$0")" && pwd)

STRAP_ARGS=()
IMAGE_SUFFIX=

while getopts 'fs:' c; do
	case "$c" in
	f)
		#
		# Use -f to request a full reset from the image builder, thus
		# effectively destroying any existing files and starting from a
		# freshly installed set of OS files.
		#
		STRAP_ARGS+=( '--fullreset' )
		;;
	s)
		#
		# You can customise the strap image by swapping out the middle
		# stage, 02-image.  Normally this takes the expensive base OS
		# step (01-strap) and adds a few extra packages for
		# convenience.  If you specify a -s option here, e.g.,
		# "-s mine", we will look for, e.g.,
		# "hipster-02-image-mine.json" instead of the stock
		# "hipster-02-image.json".
		#
		IMAGE_SUFFIX="-$OPTARG"
		;;
	\?)
		printf 'usage: %s [-f]\n' "$0" >&2
		exit 2
		;;
	esac
done
shift $((OPTIND - 1))

cd "$TOP"

for n in 01-strap "02-image$IMAGE_SUFFIX" 03-archive; do
	ARGS=()
	if [[ $n == 01-strap ]]; then
		ARGS=( "${STRAP_ARGS[@]}" )
	fi
	banner "$n"
	pfexec "$TOP/image-builder/target/debug/image-builder" \
	    build \
	    -T "$TOP/templates" \
	    -d "$DATASET" \
	    -g "$DISTRO" \
	    -n "$BRANCH-$n" \
	    "${ARGS[@]}"
done

ls -lh "$MOUNTPOINT/output/$DISTRO-$BRANCH.tar.gz"
