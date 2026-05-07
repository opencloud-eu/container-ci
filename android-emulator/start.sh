#!/usr/bin/env bash
set -e

AVD_NAME="android"
MEMORY="${MEMORY:-4096}"
CORES="${CORES:-4}"
PARTITION="${PARTITION:-8192}"

Xvfb :0 -screen 0 1024x768x24 &
sleep 2

echo "==> Starting ADB server..."
adb -a -P 5037 server nodaemon &

# Forward the emulator's console port to the host machine so that we can connect to it from outside the container.
LOCAL_IP=$(ip addr list eth0 | grep "inet " | cut -d' ' -f6 | cut -d/ -f1)
socat tcp-listen:5555,bind="${LOCAL_IP}",reuseaddr,fork tcp:127.0.0.1:5555 &

if ! avdmanager list avd | grep -q "Name: ${AVD_NAME}"; then
  echo "==> Creating AVD (API ${API_LEVEL}, ${IMG_TYPE}/${ARCHITECTURE})..."
  echo "no" | avdmanager create avd \
    --name "${AVD_NAME}" \
    --abi "${IMG_TYPE}/${ARCHITECTURE}" \
    --package "system-images;android-${API_LEVEL};${IMG_TYPE};${ARCHITECTURE}" \
    --device "${DEVICE_ID}" \
    --force
fi

echo "==> Starting emulator..."

if [ "${GPU_ACCELERATED:-false}" == "true" ]; then
  GPU_MODE="host"
  echo "==> GPU acceleration ENABLED"
else
  GPU_MODE="swiftshader_indirect"
  echo "==> GPU acceleration DISABLED (software rendering)"
fi

if [ -e "/dev/kvm" ]; then
  KVM_FLAGS="-accel on"
  echo "==> KVM acceleration ENABLED"
else
  KVM_FLAGS="-accel tcg"
  echo "==> KVM acceleration DISABLED (slow)"
fi

# Start the emulator
emulator \
  -avd "${AVD_NAME}" \
  -no-window \
  -no-audio \
  -no-boot-anim \
  -no-snapshot \
  ${KVM_FLAGS} \
  -gpu "${GPU_MODE}" \
  -memory "${MEMORY}" \
  -cores "${CORES}" \
  -partition-size "${PARTITION}" \
  -skip-adb-auth \
  -verbose

# If the emulator crashes, print the reason
if [ $? -ne 0 ]; then
  echo "==> Emulator crashed! Check logs above."
  exit 1
fi