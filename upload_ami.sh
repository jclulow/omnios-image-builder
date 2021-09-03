#!/bin/bash

#
# Upload a raw disk image into AWS and register it as an AMI.  The image must
# have been built first, and at a location of the form:
#
#     /rpool/images/output/aws-omnios-stable.raw
#
# This tool requires "setup.sh" and "aws.sh" to have been run first to create
# the image.
#

set -o xtrace
set -o pipefail
set -o errexit

BUCKET=$1
AMI_NAME=$2
if [[ -z "$BUCKET" || -z "$AMI_NAME" ]]; then
	printf 'ERROR: usage: %s <bucket> <ami_name>\n' "$0" >&2
	exit 1
fi

DATASET=rpool/images
MOUNTPOINT="$(zfs get -Ho value mountpoint "$DATASET")"
DISTRO=${DISTRO:-omnios}
BRANCH=${BRANCH:-stable}
FILE="$MOUNTPOINT/output/aws-$DISTRO-$BRANCH.raw"

if [[ ! -f "$FILE" ]]; then
	printf 'image file %s does not exist yet?\n' "$FILE" >&2
	exit 1
fi

TOP=$(cd "$(dirname "$0")" && pwd)

cd "$TOP"

S3_PREFIX="amifromfile-$RANDOM$RANDOM$RANDOM"

time "$TOP/aws-wire-lengths/target/debug/aws-wire-lengths" \
    ami-from-file \
    -p "$S3_PREFIX" \
    -f "$FILE" \
    -b "$BUCKET" \
    -n "$AMI_NAME"
