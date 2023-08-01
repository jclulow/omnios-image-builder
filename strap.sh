#!/bin/bash

#
# Use the Image Builder to produce a tar file that contains an installed OmniOS
# image.  The produced file should be something like:
#
#     /rpool/images/output/omnios-stable-r151046.tar.gz
#
# This tool requires "setup.sh" to have been run first.
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

STRAP_ARGS=()
ALL_ARGS=()
IMAGE_SUFFIX=

while getopts 'BEfs:' c; do
	case "$c" in
	f)
		#
		# Use -f to request a full reset from the image builder, thus
		# effectively destroying any existing files and starting from a
		# freshly installed set of OS files.
		#
		STRAP_ARGS+=( '--fullreset' )
		;;
	E)
		#
		# Enable OmniOS Extra (Additional packages) publisher.
		#
		ALL_ARGS+=( '-F' 'extra' )
		;;
	B)
		#
		# Install software build tools.
		#
		ALL_ARGS+=( '-F' 'build' )
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
	    -F "release=$RELEASE" \
	    "${ALL_ARGS[@]}" \
	    "${ARGS[@]}"
done

ls -lh "$MOUNTPOINT/output/$DISTRO-$BRANCH.tar.gz"
