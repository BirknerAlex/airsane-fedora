#!/usr/bin/env bash
# Build AirSane from source and package it as an RPM with nFPM.
# Run inside a Fedora container (see .github/workflows/release.yml).
#   AIRSANE_REF  upstream git tag (default: contents of AIRSANE_VERSION)
#   RELEASE      package release number (default: 1)
set -euo pipefail
cd "$(dirname "$0")/.."

AIRSANE_REF="${AIRSANE_REF:-$(tr -d '[:space:]' < AIRSANE_VERSION)}"
export VERSION="${AIRSANE_REF#v}"
export RELEASE="${RELEASE:-1}"
export ARCH="${ARCH:-$(uname -m)}"
NFPM_VERSION="${NFPM_VERSION:-2.47.0}"

dnf install -y git cmake gcc-c++ make curl tar \
  sane-backends-devel libjpeg-turbo-devel libpng-devel avahi-devel libusb1-devel

rm -rf src build
git clone --depth 1 --branch "$AIRSANE_REF" https://github.com/SimulPiscator/AirSane.git src
cmake -S src -B build
cmake --build build -j"$(nproc)"

case "$ARCH" in x86_64) NFPM_ARCH=x86_64 ;; aarch64) NFPM_ARCH=arm64 ;; *) echo "unsupported arch $ARCH"; exit 1 ;; esac
curl -sSL "https://github.com/goreleaser/nfpm/releases/download/v${NFPM_VERSION}/nfpm_${NFPM_VERSION}_Linux_${NFPM_ARCH}.tar.gz" \
  | tar -xz -C /usr/local/bin nfpm

mkdir -p dist
nfpm package --config nfpm.yaml --packager rpm --target dist/
ls -l dist
