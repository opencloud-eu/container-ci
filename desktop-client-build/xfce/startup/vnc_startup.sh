#!/bin/bash

VNC_LOG_FILE="${HOME}"/.vnc/vnc_startup.log

start_vnc () {
    local vnc_ip
    local passwd_path

    if [[ -z "$(which vncserver)" ]] ; then
        echo "[WARNING] No 'vncserver' is available."
        return 0
    fi

    ### VNC requirements
    if [[ -z "${DISPLAY}" \
    || -z "${VNC_PORT}" \
    || -z "${VNC_COL_DEPTH}" \
    || -z "${VNC_RESOLUTION}" ]] ; then
        echo "[ERROR] Not all required environment variables are set: DISPLAY, VNC_PORT, VNC_COL_DEPTH, VNC_RESOLUTION"
        return 1
    fi

    passwd_path="${HOME}"/.vnc/passwd
    mkdir -p "${HOME}"/.vnc
    touch ~/.Xauthority
    mkdir -p /tmp/.X11-unix

    ### create VNC password file with the provided password
    echo "${VNC_PW}" | vncpasswd -f > "${passwd_path}"
    chmod 600 "${passwd_path}"

    ### create VNC configuration file
    echo "
    rfbport=${VNC_PORT}
    depth=${VNC_COL_DEPTH}
    geometry=${VNC_RESOLUTION}
    " > "${HOME}"/.vnc/config

    ### get container IP address
    vnc_ip=$(hostname -i)

    ### VNC startup (in the background)
    echo "[INFO] Starting VNC..."
    echo "vncserver ${DISPLAY} &> ${VNC_LOG_FILE}"
    vncserver "${DISPLAY}" &> "${VNC_LOG_FILE}" &

    ### container will wait on this VNC server PID
    _wait_pid=$!

    echo "[INFO] VNC server started on display '${DISPLAY}' and TCP port '${VNC_PORT}'"
    echo "[INFO] Connect via VNC viewer with ${vnc_ip}:${VNC_PORT}"
    tail -f "${VNC_LOG_FILE}"
}

function wait_for_vnc() {
    line="Created VNC server for screen"
    until cat "${VNC_LOG_FILE}" 2>/dev/null | grep -q "$line" ; do
        sleep 1
    done
    cat "${VNC_LOG_FILE}"
}