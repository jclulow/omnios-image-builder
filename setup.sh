#!/bin/bash

#
# Clone the repositories for the tools we require and run their build steps.
#

set -o xtrace
set -o pipefail
set -o errexit

TOP=$(cd "$(dirname "$0")" && pwd)
FILES="$TOP/templates/files"

cd "$TOP"
if [[ ! -d image-builder ]]; then
	git clone git@github.com:illumos/image-builder.git \
	    image-builder
fi

if [[ ! -d metadata-agent ]]; then
	git clone git@github.com:illumos/metadata-agent.git \
	    metadata-agent
fi

(cd image-builder && cargo build --release)
(cd metadata-agent && cargo build --release)

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
