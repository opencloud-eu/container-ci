#!/bin/bash

#set -e     ### do not use this

declare _thisdir=$(dirname $0)

source "${_thisdir}"/vnc_startup.sh

start_vnc >/dev/null 2>&1 &
echo "[INFO] Test environment initialized, waiting for VNC server to be ready..."
wait_for_vnc

# set up DBUS_SESSION_BUS_ADDRESS for the test processes
# to be able to connect to the session bus
xfce_pid=$(pgrep -n xfce4-session)
export DBUS_SESSION_BUS_ADDRESS=$(tr '\0' '\n' < /proc/$xfce_pid/environ | grep DBUS_SESSION_BUS_ADDRESS | cut -d= -f2-)

# start and unlock keyring
echo -n "${VNC_PW}" | gnome-keyring-daemon -r --unlock 2>/dev/null > keyring.env
source keyring.env

if [[ -n "${PYTHONUSERBASE}" ]] ; then
    export PATH="${PYTHONUSERBASE}/bin:${PATH}"
fi

if [[ -z "${BEHAVE_TEST_DIR}" ]]; then
    echo "[ERROR] BEHAVE_TEST_DIR environment variable is not provided."
    exit 1
fi

if [[ -z "${GUI_TEST_REPORT_DIR}" ]]; then
    export GUI_TEST_REPORT_DIR="${BEHAVE_TEST_DIR}/reports"
fi
mkdir -p "${GUI_TEST_REPORT_DIR}"

cd "${BEHAVE_TEST_DIR}" || exit 1

if [[ -n "${WEBDRIVER_RUNNER}" ]]; then
    echo ""
    echo "##########################[ AT-SPI WebDriver ]##########################"
    if [[ ! -f "${WEBDRIVER_RUNNER}" ]] ; then
        echo "[ERROR] WebDriver runner script '${WEBDRIVER_RUNNER}' does not exist."
        exit 1
    fi

    echo "[INFO] Running AT-SPI WebDriver: ${WEBDRIVER_RUNNER}"

    if [[ -z "${WEBDRIVER_HOST}" ]]; then
        export WEBDRIVER_HOST="0.0.0.0"
    fi
    if [[ -z "${WEBDRIVER_PORT}" ]]; then
        export WEBDRIVER_PORT="4723"
    fi

    bash "${WEBDRIVER_RUNNER}" > "$GUI_TEST_REPORT_DIR/atspi_webdriver.log" 2>&1 &
    webdriver_pid=$!

    start_time=$(date +%s)
    # check with 60 seconds timeout
    timeout=60
    while ! curl "http://${WEBDRIVER_HOST}:${WEBDRIVER_PORT}" -w "%{http_code}" -so /dev/null | grep -q "200" ; do
        end_time=$(date +%s)
        elapsed=$((end_time - start_time))
        # check if PID is still running
        if ! kill -0 "$webdriver_pid" 2>/dev/null; then
            echo "[ERROR] WebDriver process exited unexpectedly."
            exit 1
        fi
        if [[ $elapsed -ge $timeout ]]; then
            echo "[ERROR] WebDriver was not ready within 60 seconds."
            exit 1
        fi
        sleep 1
    done
    echo "[INFO] WebDriver is ready on ${WEBDRIVER_HOST}:${WEBDRIVER_PORT}."
fi

echo ""
echo "#############################[ GUI Tests ]#############################"
echo "[INFO] Run GUI tests: behave ${BEHAVE_PARAMETERS}"
behave ${BEHAVE_PARAMETERS}