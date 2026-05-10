# GitHub Secrets 

This branch (`feature/developer-dashboard-token-gated`) is the Google Play safe
developer-dashboard branch. It does not build or install APK updates from
GitHub, so it does not require Android signing secrets.

## Required for this branch

No custom repository secrets are required.

The workflow uses GitHub Actions' built-in `GITHUB_TOKEN` to create or update a
GitHub Release containing `release/version.json`. Keep the workflow permission:

```yaml
permissions:
  contents: write
```

## Developer dashboard access

Developers unlock the hidden dashboard inside a debug build with a fine-grained
GitHub personal access token. Do not store this token in GitHub Actions secrets
for this branch; each developer should paste their own token into the hidden
dashboard on their device.

Minimum token access:

- Repository access: only `Money-Mansion/money-mansion`
- Repository permissions: `Contents: Read-only`
- Repository permissions: `Metadata: Read-only`

## Not required on this branch

These secrets are only needed on the internal APK updater branch that builds and
ships APK files through GitHub Releases:

- `ANDROID_KEYSTORE_BASE64`
- `ANDROID_KEY_ALIAS`
- `ANDROID_KEY_PASSWORD`
- `ANDROID_STORE_PASSWORD`

Do not add APK install permissions or GitHub APK update logic to this branch if
the artifact will be uploaded to Google Play.
