# GitHub Secrets 

This Google Play branch keeps developer dashboard behavior out of release
artifacts. It does not build or install APK updates from GitHub automatically,
so normal Google Play work does not require Android signing secrets.

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

## Optional manual internal APK workflow

The manual internal APK workflow is not required for Google Play releases. If a
maintainer runs it for internal testing, it must publish a prerelease and must
not mark the release as latest. That optional workflow needs:

- `ANDROID_KEYSTORE_BASE64`
- `ANDROID_KEY_ALIAS`
- `ANDROID_KEY_PASSWORD`
- `ANDROID_STORE_PASSWORD`

Do not add APK install permissions or GitHub APK update logic to this branch if
the artifact will be uploaded to Google Play.
