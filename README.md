# airsane-fedora

RPMs for Fedora built with [nFPM](https://nfpm.goreleaser.com) and published to a [silo](https://github.com/BirknerAlex/silo) repo (`airsane`, channel `stable`). One directory per package, sources as git submodules (`src/`), pinned by commit:

- `airsane/`: [AirSane](https://github.com/SimulPiscator/AirSane) (SANE scanners as eSCL/AirScan). Version in `airsane/VERSION`, must match the submodule tag.
- `sane-backends/`: package `sane-backends-upstream`, upstream SANE (libsane + `xerox_mfp` only) in `/opt/sane`, next to Fedora's `sane-backends` without touching it. Run airsaned with `LD_LIBRARY_PATH=/opt/sane/lib`. Carries the xerox_mfp TCP fixes Fedora's 1.4.0 lacks. `sane-backends/VERSION` is the last release the pinned commit is based on.

To update a package: move the submodule (`git -C <pkg>/src checkout <ref>`), adjust `VERSION`, commit. Push a tag `r<N>` to build both packages in a Fedora container and publish them with release number `N`.

Required secret: `SILO_AIRSANE_TOKEN`.
