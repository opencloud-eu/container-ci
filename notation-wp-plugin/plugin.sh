#!/bin/sh

set -e

echo "setup signing keys"
echo "${PLUGIN_KEY}" > /root/.config/notation/localkeys/oc-ci.key
echo "${PLUGIN_CRT}" > /root/.config/notation/localkeys/oc-ci.crt

echo "setting up registry logins"
echo "${PLUGIN_LOGINS}" > /root/tmp.logins.json
jq 'map({(.registry): {auth: ( (.username + ":" + .password) | @base64 )} }) | add | {auths: .}' /root/tmp.logins.json > /root/.config/notation/config.json
cp /root/.config/notation/config.json /root/.docker/config.json

echo "getting digest for $PLUGIN_TARGET"
export DIGEST=$(oras manifest fetch --descriptor $PLUGIN_TARGET | jq -r '.digest')

echo "begin signing"

primary=$(echo ${PLUGIN_TARGET} | sed -e 's/:.*//')
echo "##### start sign for $primary@$DIGEST #####"
notation sign $primary@$DIGEST

if [[ -n "${PLUGIN_ADDITIONAL}" ]]; then
    echo ${PLUGIN_ADDITIONAL} | tr ',' '\n' | while read target
    do
        set -e
        # Trim whitespace and skip empty
        target=$(echo "$target" | xargs)
        if [ -z "$target" ]; then
            continue
        fi
        echo "##### start sign for $target@$DIGEST #####"
        notation sign $target@$DIGEST
    done
fi

exit 0
