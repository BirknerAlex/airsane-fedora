# airsane-fedora

RPMs for Fedora built with [nFPM](https://nfpm.goreleaser.com) and published to a [silo](https://github.com/BirknerAlex/silo) repo (`airsane`, channel `stable`). One directory per package, sources as git submodules (`src/`), pinned by commit:

- `airsane/`: [AirSane](https://github.com/SimulPiscator/AirSane) (SANE scanners as eSCL/AirScan). Version in `airsane/VERSION`, must match the submodule tag.
- `sane-backends/`: package `sane-backends-upstream`, upstream SANE (libsane + `xerox_mfp` only) in `/opt/sane`, next to Fedora's `sane-backends` without touching it. Run airsaned with `LD_LIBRARY_PATH=/opt/sane/lib`. Carries the xerox_mfp TCP fixes Fedora's 1.4.0 lacks. `sane-backends/VERSION` is the last release the pinned commit is based on.

## Install

The packages are in a public [silo](https://silo.tyrola.dev) repo, signed with its RPM key:

```ini
# /etc/yum.repos.d/silo-airsane.repo
[silo-airsane]
name=Silo airsane/stable
baseurl=https://silo.tyrola.dev/airsane/stable
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://silo.tyrola.dev/RPM-GPG-KEY-silo
```

```sh
sudo dnf install airsane sane-backends-upstream
```

`airsane` installs `airsaned` with a systemd unit and an `airsane` user. To scan through the upstream SANE build, add a drop-in (`systemctl edit airsaned`):

```ini
[Service]
Environment=LD_LIBRARY_PATH=/opt/sane/lib
```

Configure the scanner as usual in `/etc/sane.d/` (for a network Samsung/Xerox MFP: a `tcp <ip> 9400` line in `xerox_mfp.conf`), then `systemctl enable --now airsaned`. Built for Fedora 45 (x86_64).

## Updating

To update a package: move the submodule (`git -C <pkg>/src checkout <ref>`), adjust `VERSION`, commit. Push a tag `r<N>` to build both packages in a Fedora container and publish them with release number `N`.

Required secret: `SILO_AIRSANE_TOKEN`.
