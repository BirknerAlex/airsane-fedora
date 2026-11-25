# airsane-fedora

[AirSane](https://github.com/SimulPiscator/AirSane) (SANE scanners as eSCL/AirScan) packaged as an RPM for Fedora with [nFPM](https://nfpm.goreleaser.com), published to a [silo](https://github.com/BirknerAlex/silo) repo.

- `AIRSANE_VERSION`: upstream tag to build.
- Push a tag `v<airsane version>-<release>` (e.g. `v0.4.16-1`) to build in a Fedora container and publish to silo (`repo: airsane`, `channel: stable`).
- Installs `/usr/sbin/airsaned`, the systemd unit, a sysusers entry for `airsane` and `/etc/airsane/*.conf` (`noreplace`). Host-specific flags/environment belong in a drop-in `airsaned.service.d/`.

A second package, `sane-backends-upstream`, is upstream SANE (libsane + `xerox_mfp` only) built from the commit in `SANE_BACKENDS_REF` into `/opt/sane`, next to Fedora's `sane-backends` without touching it. Run airsaned with `LD_LIBRARY_PATH=/opt/sane/lib` to use it. It carries the xerox_mfp TCP fixes that Fedora's 1.4.0 lacks.

Required secret: `SILO_AIRSANE_TOKEN`.
