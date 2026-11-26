# Building the IPA on GitHub Actions

The workflow `.github/workflows/build-ipa.yml` runs on a GitHub macOS runner with Xcode.

- **Every run** compiles `YouTubeCarPlay.dylib`, runs the packaging tests, and uploads the module as an artifact.
- **With an input IPA** it also injects the module into your YouTube + YouMod IPA and uploads the result as a password-protected zip.

Run it from **Actions → Build YouDash IPA → Run workflow**. It also runs on pushes that change the module, scripts or tests.

## Secrets

Add these under **Settings → Secrets and variables → Actions → New repository secret**.

| Secret | Required for | What it is |
| --- | --- | --- |
| `YOUTUBE_IPA_URL` | IPA build | Direct download link to your **decrypted** YouTube + YouMod IPA (baseline: YouTube 21.42.4 + YouMod 2.0.0). Use a private link you control, for example a private release asset or a cloud-storage link with a token. |
| `ARTIFACT_PASSWORD` | IPA build | Password for the AES-256 zip the IPA is uploaded in. This repository is public, and anyone with a GitHub account can download artifacts from public repositories. The IPA contains Google's app, so it is never uploaded unencrypted. |
| `SIGNING_CERT_P12_BASE64` | Signed IPA | Your Apple development or distribution certificate with its private key, exported as `.p12`, then base64 encoded: `base64 -i cert.p12 \| pbcopy` |
| `SIGNING_CERT_PASSWORD` | Signed IPA | The `.p12` export password. |
| `PROVISIONING_PROFILE_BASE64` | Signed IPA | Your `.mobileprovision`, base64 encoded. It **must** include `com.apple.developer.carplay-video` and list your iPhone's UDID (development / ad hoc). The bundle ID is taken from this profile. |

Secret values are never written to the build log. Keep the input URL in a secret and not in a workflow input, because run inputs are visible to anyone on a public repository.

## Which IPA you get

- **Signing secrets set:** a signed IPA, ready to install on the iPhones listed in the profile. You can use Apple Configurator, Finder (drag onto the device), `xcrun devicectl device install app`, or any installer that keeps the existing signature.
- **No signing secrets:** an unsigned IPA (`*-unsigned.ipa`). You must sign it yourself before it will install, for example with Sideloadly or `codesign`, using a profile that has the CarPlay video entitlement.

> **CarPlay video entitlement.** A free Apple ID, or an ordinary paid profile without `com.apple.developer.carplay-video`, lets the app install and run on the phone, but it **will not appear as a video app on CarPlay**. The entitlement must come from Apple through your developer account. Nothing in this repository can grant or bypass it.

## Downloading

1. Open the finished run and download **YouDash-ipa-encrypted**. Artifacts expire after 3 days.
2. GitHub wraps it in a zip. Extract that, then open `YouDash-ipa.zip` with your `ARTIFACT_PASSWORD`. On macOS, use `7zz x YouDash-ipa.zip` or The Unarchiver. Finder's built-in unzip does not support AES.
3. Inside are the `.ipa` and `build-manifest.json`, which lists the input and output hashes.
