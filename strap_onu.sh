#!/bin/bash

#
# Use the Image Builder to produce a tar file that contains an installed
# OpenIndiana image with an onu from a local workspace.
#
# The produced file should be something like:
#
#     /rpool/images/output/openindiana-hipster.tar.gz
#
# This tool requires "setup.sh" to have been run first.
#

set -o xtrace
set -o pipefail
set -o errexit

export DISTRO=${DISTRO:-openindiana}
export BRANCH=${BRANCH:-hipster}

TOP=$(cd "$(dirname "$0")" && pwd)

cd "$TOP"

if [[ -z "$GATE" || ! -d "$GATE/packages/i386/nightly-nd/repo.redist" ]]; then
	printf 'ERROR: set GATE to the workspace root\n' >&2
	exit 1
fi

#
# Attempt to ensure a fully-qualified path to the workspace:
#
GATE=$(cd "$GATE" && pwd)

#
# XXX Doctor the template to include the path of the local workspace.  There is
# currently no macro expansion so we need to make a new template file.
#
rm -f templates/openindiana/hipster-02-image-onu.json
cp templates/openindiana/hipster-02-image.json \
    templates/openindiana/hipster-02-image-onu.json
ed -s templates/openindiana/hipster-02-image-onu.json <<EOF
/pkg_purge_history/i
        { "t": "onu", "publisher": "openindiana.org",
            "repo": "file:///$GATE/packages/i386/nightly-nd/repo.redist" },

.
w
EOF

#
# NOTE: See strap.sh for arguments that are also valid here.
#
./strap.sh -s onu "$@"
