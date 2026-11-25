#!/usr/bin/env bash
# Build upstream SANE (only the xerox_mfp backend + libsane) into /opt/sane and
# package it as an RPM with nFPM. It sits next to Fedora's sane-backends
# without touching it; airsaned picks it up via LD_LIBRARY_PATH=/opt/sane/lib.
# Run inside a Fedora container (see .github/workflows/release.yml).
#   SANE_REF   upstream commit/tag (default: contents of SANE_BACKENDS_REF)
#   RELEASE    package release number (default: 1)
set -euo pipefail
cd "$(dirname "$0")/.."

SANE_REF="${SANE_REF:-$(tr -d '[:space:]' < SANE_BACKENDS_REF)}"
export RELEASE="${RELEASE:-1}"
export ARCH="${ARCH:-$(uname -m)}"
NFPM_VERSION="${NFPM_VERSION:-2.47.0}"

dnf install -y git curl tar gcc gcc-c++ make autoconf automake libtool gettext-devel \
  pkgconf-pkg-config libusb1-devel libjpeg-turbo-devel libpng-devel libtiff-devel \
  libxml2-devel avahi-devel

rm -rf sane-src stage
git clone https://gitlab.com/sane-project/backends.git sane-src
git -C sane-src checkout "$SANE_REF"

# 1.4.0.git<date>.<short sha>: sorts above the 1.4.0 release.
base="$(git -C sane-src describe --tags --abbrev=0 2>/dev/null || echo 1.4.0)"
date="$(git -C sane-src show -s --format=%cd --date=format:%Y%m%d)"
export VERSION="${base#RELEASE_}.git${date}.$(git -C sane-src rev-parse --short=9 HEAD)"
VERSION="${VERSION//-/.}"
echo "version: $VERSION"

cd sane-src
./autogen.sh
BACKENDS="xerox_mfp" ./configure --prefix=/opt/sane --sysconfdir=/etc \
  --disable-locking --disable-latex --disable-dependency-tracking
make -j"$(nproc)"
make install DESTDIR="$PWD/../stage"
cd ..

case "$ARCH" in x86_64) NFPM_ARCH=x86_64 ;; aarch64) NFPM_ARCH=arm64 ;; *) echo "unsupported arch $ARCH"; exit 1 ;; esac
curl -sSL "https://github.com/goreleaser/nfpm/releases/download/v${NFPM_VERSION}/nfpm_${NFPM_VERSION}_Linux_${NFPM_ARCH}.tar.gz" \
  | tar -xz -C /usr/local/bin nfpm

mkdir -p dist
nfpm package --config nfpm-sane-backends.yaml --packager rpm --target dist/
ls -l dist
