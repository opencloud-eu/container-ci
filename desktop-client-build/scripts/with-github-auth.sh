#!/bin/sh
#
# Run a command with git authenticating against github.com.
#
# Anonymous git clones from github.com are rate limited per source IP and get
# rejected with HTTP 401 once the limit is hit. Craft clones several
# repositories from github.com while installing the desktop client
# dependencies, so the build needs authenticated access.
#
# The token is expected as a BuildKit secret mounted at /run/secrets/GITHUB_TOKEN
# (docker build --secret id=GITHUB_TOKEN). It is only ever exposed to the
# command run by this script, as an HTTP header via git's GIT_CONFIG_* env
# vars, and never written to a file or image layer.
#
# Without the secret the command runs unchanged and git clones anonymously.

set -eu

secret_file="${GITHUB_TOKEN_FILE:-/run/secrets/GITHUB_TOKEN}"

if [ -s "$secret_file" ]; then
    auth="$(printf 'x-access-token:%s' "$(cat "$secret_file")" | base64 | tr -d '\n')"
    export GIT_CONFIG_COUNT=1
    export GIT_CONFIG_KEY_0="http.https://github.com/.extraheader"
    export GIT_CONFIG_VALUE_0="AUTHORIZATION: basic ${auth}"
    echo "with-github-auth: GITHUB_TOKEN secret found, git authenticates against github.com"
else
    echo "with-github-auth: no GITHUB_TOKEN secret, git clones from github.com anonymously"
fi

exec "$@"
