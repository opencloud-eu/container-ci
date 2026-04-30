#!/bin/bash

#set -e     ### do not use this

declare _thisdir=$(dirname $0)

source "${_thisdir}"/vnc_startup.sh

start_vnc >/dev/null 2>&1 &
echo "[INFO] Test environment initialized, waiting for VNC server to be ready..."
wait_for_vnc

if [[ -n "${PYTHONUSERBASE}" ]] ; then
    export PATH="${PYTHONUSERBASE}/bin:${PATH}"
fi

if [[ -z "${BEHAVE_TEST_DIR}" ]]; then
    echo "[ERROR] BEHAVE_TEST_DIR environment variable is not provided."
    exit 1
fi

cd "${BEHAVE_TEST_DIR}" || exit 1

echo ""
echo "#################################################################"
echo "[INFO] Run GUI tests: behave ${BEHAVE_PARAMETERS}"
behave ${BEHAVE_PARAMETERS}