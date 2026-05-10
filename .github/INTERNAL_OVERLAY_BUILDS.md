# Internal Overlay Builds

Use `Android Internal Overlay APK` when you want to install a branch, tag, or
old commit that does not already contain the internal updater.

The workflow is read-only for source branches:

- It checks out the target ref into `target/`.
- It checks out `feature/internal-github-apk-updater` into `updater/`.
- It copies the updater files into the disposable `target/` workspace.
- It builds and signs an APK from that temporary workspace.
- It creates a GitHub Release with `app-release.apk` and `version.json`.

It does not commit, merge, push, or rewrite `main`, the target branch, or the
internal updater branch.

## Inputs

- `target_ref`: branch, tag, or commit SHA to build.
- `updater_ref`: updater source branch. Keep this as
  `feature/internal-github-apk-updater` unless you intentionally test another
  updater branch.
- `release_tag`: optional. Leave empty for an automatic tag.
- `release_channel`: label shown in the Developer Dashboard build switcher.
- `changelog`: text shown in the updater UI.
- `make_latest`: normally keep this off. The build switcher can still install
  prerelease overlay builds.

## Version Codes

Overlay builds use a timestamp build number. That keeps internal APK version
codes moving upward even when the source code is from an old commit, so Android
can install the old app code as a normal update.

The APK still must be signed with the same internal signing key as the app that
is currently installed on the device.
