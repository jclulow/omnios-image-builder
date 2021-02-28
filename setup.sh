#!/bin/bash

#
# Clone the repositories for the tools we require and run their build steps.
#

set -o xtrace
set -o pipefail
set -o errexit

TOP=$(cd "$(dirname "$0")" && pwd)
FILES="$TOP/templates/files"

function github_url {
	local org=$1
	local repo=$2
	local protocol=$3

	if [[ -n "$PROTOCOL" ]]; then
		protocol=$PROTOCOL
	elif [[ -z "$protocol" ]]; then
		protocol=https
	fi

	case "$protocol" in
	ssh)
		printf 'git@github.com:%s/%s.git' "$org" "$repo"
		;;
	https)
		printf 'https://github.com/%s/%s.git' "$org" "$repo"
		;;
	*)
		printf 'ERROR: invalid git transport: %s\n' "$protocol" >&2
		exit 1
	esac
}

function github_clone {
	local org=$1
	local repo=$2
	local dirname=$3
	local protocol=$4
	local url=

	if [[ -d "$dirname" ]]; then
		if ! (cd "$dirname" && git pull --rebase); then
			return 1
		fi
		return 0
	fi

	if ! url=$(github_url "$org" "$repo" $protocol); then
		return 1
	fi

	git clone "$url" "$dirname"
}

cd "$TOP"
github_clone illumos		image-builder		image-builder
github_clone illumos		metadata-agent		metadata-agent
github_clone oxidecomputer	aws-wire-lengths	aws-wire-lengths

(cd image-builder && cargo build --release)
(cd metadata-agent && cargo build --release)
(cd aws-wire-lengths && cargo build --release)

mkdir -p "$FILES"

#
# Copy the output of the Metadata Agent build to the place where the Image
# Builder tool looks for files to include in images:
#
for f in \
    metadata \
    metadata.xml \
    userscript.sh \
    userscript.xml; do
	ff="$FILES/$f"
	rm -f "$ff"
	if [[ $f == metadata ]]; then
		cp "$TOP/metadata-agent/target/release/$f" "$ff"
	else
		cp "$TOP/metadata-agent/$f" "$ff"
	fi
done
