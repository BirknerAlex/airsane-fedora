#!/usr/bin/env bash
# Build upstream SANE (submodule ./src, pinned commit; only libsane + the
# xerox_mfp backend) into /opt/sane and package it as an RPM with nFPM. It sits
# next to Fedora's sane-backends without touching it; airsaned picks it up via
# LD_LIBRARY_PATH=/opt/sane/lib.
# Run inside a Fedora container (see .github/workflows/release.yml).
#   RELEASE  package release number (default: 1)
set -euo pipefail
cd "$(dirname "$0")"

export RELEASE="${RELEASE:-1}"
export ARCH="${ARCH:-$(uname -m)}"
NFPM_VERSION="${NFPM_VERSION:-2.47.0}"

dnf install -y git curl tar gcc gcc-c++ make autoconf autoconf-archive automake libtool gettext-devel \
  pkgconf-pkg-config libusb1-devel libjpeg-turbo-devel libpng-devel libtiff-devel \
  libxml2-devel avahi-devel

# <last release>.git<commit date>.<short sha>: sorts above the release itself.
git config --global --add safe.directory '*'
date="$(git -C src show -s --format=%cd --date=format:%Y%m%d)"
export VERSION="$(tr -d '[:space:]' < VERSION).git${date}.$(git -C src rev-parse --short=9 HEAD)"
echo "version: $VERSION"

rm -rf stage
cd src
./autogen.sh
BACKENDS="xerox_mfp" ./configure --prefix=/opt/sane --sysconfdir=/etc \
  --disable-locking --disable-latex --disable-dependency-tracking
make -j"$(nproc)"
make install DESTDIR="$PWD/../stage"
cd ..

case "$ARCH" in x86_64) NFPM_ARCH=x86_64 ;; aarch64) NFPM_ARCH=arm64 ;; *) echo "unsupported arch $ARCH"; exit 1 ;; esac
command -v nfpm >/dev/null || curl -sSL "https://github.com/goreleaser/nfpm/releases/download/v${NFPM_VERSION}/nfpm_${NFPM_VERSION}_Linux_${NFPM_ARCH}.tar.gz" \
  | tar -xz -C /usr/local/bin nfpm

mkdir -p ../dist
nfpm package --config nfpm.yaml --packager rpm --target ../dist/
ls -l ../dist
