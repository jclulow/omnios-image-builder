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
	pfexec "$TOP/image-builder/target/release/image-builder" \
	    build \
	    -T "$TOP/templates" \
	    -d "$DATASET" \
	    -g omnios \
	    -n "$BRANCH-$n" \
	    "${ARGS[@]}"
done

ls -lh "$MOUNTPOINT/output/omnios-$BRANCH.tar.gz"
