# Applying the CI release-publish patch (one-time, manual)

The GitHub App used for this repository cannot push changes to
`.github/workflows/*` (it lacks the `workflows` permission), so the
workflow change that publishes APK releases is delivered as a patch.

## What it does

After a manual **Build Android APK** run (`workflow_dispatch`), the
workflow:

1. Computes a version stamp = minutes since the Unix epoch
   (`APP_VERSION_STAMP`).
2. Builds the APK with `versionCode`/`versionName = 1.0.0.<stamp>`
   (Gradle already reads `APP_VERSION_STAMP` from the environment, see
   `android-apk/app/build.gradle`), so every build is strictly newer than
   the previous one and **installs over the existing app** — no
   uninstall, saves and game files are preserved.
3. Publishes (or updates) a GitHub release tagged `1.0.0.<stamp>` with
   the APK attached.

The launcher's **Check for updates** button (`UpdateManager`) then finds
that release, downloads the APK, verifies it is signed by the same key,
and hands it to the system installer — a true in-place update.

## Apply it

In a checkout of this repository run:

```bash
git apply tools/ci/workflow-release-publish.patch
```

or, from the GitHub web UI, edit `.github/workflows/build-android-apk.yml`
and paste the diff from `tools/ci/workflow-release-publish.patch`.

The same content is kept at `tools/ci/build-android-apk.yml` (which can
be updated by pushes) — copy it over `.github/workflows/` if you prefer.

## Notes

- The debug keystore is cached in CI (`actions/cache`), so the APK
  signature is identical across runs and install-over works.
- Requires `permissions: contents: write` on the workflow (already part
  of the patch) and a token that can create releases.
