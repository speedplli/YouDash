<div align="center">

<img src="assets/youdash-mark.svg" width="88" height="88" alt="YouDash logo">

# YouDash

### Native YouTube for Apple CarPlay

**Open source. Native playback. Ad blocking included.**

The familiar YouTube app, adapted for your car's screen—with a responsive feed, an on-screen keyboard, and video beside your playlist.

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg?style=flat-square)](LICENSE)
[![Apple CarPlay](https://img.shields.io/badge/Apple-CarPlay-111111?style=flat-square)](#features)
[![Status: Experimental](https://img.shields.io/badge/Status-Experimental-orange?style=flat-square)](docs/COMPATIBILITY.md)
[![GitHub stars](https://img.shields.io/github/stars/sa4hnd/YouDash?style=flat-square)](https://github.com/sa4hnd/YouDash/stargazers)

[**Demo**](#demo) · [**Can I install it?**](#can-i-install-it) · [**Build guide**](docs/BUILD.md) · [**How it works**](#how-it-works) · [**Report an issue**](https://github.com/sa4hnd/YouDash/issues)

</div>

## Demo

https://github.com/user-attachments/assets/3f217d50-3396-4e43-97e9-204d512d0e20

**This is the native YouTube interface and player running on a CarPlay display.** It uses a modified YouTube + YouMod app, with a custom CarPlay integration. It is not a browser wrapper or a screen-mirroring stream.

[Download the demo](https://github.com/sa4hnd/YouDash/releases/download/v0.1.0/youtube-carplay-demo.mp4)

YouDash, formerly **YouTube Car**, brings the native YouTube app to a CarPlay display with responsive layouts and YouMod ad blocking.

## Features

- **Native YouTube playback.** Browse and watch using YouTube's existing app interface and playback engine.
- **Ad blocking included through YouMod.** The development build blocks YouTube ads; effectiveness can change with YouTube updates.
- **Responsive home feed.** Video grids adapt to the display instead of stretching one phone-sized thumbnail across the screen.
- **Video on the left, queue on the right.** Landscape watch pages show your Mix, playlist, or recommendations beside the player.
- **Smaller-screen scaling.** The interface scales down to make better use of compact CarPlay displays.
- **On-screen search keyboard.** English and Arabic input, symbols, shift, and a text preview.
- **Car-friendly layout.** Sidebar-safe controls, a compact scroll-aware header, an adapted floating mini-player, and a thicker seek bar.
- **Open-source integration.** Inspect the code, build the module, and contribute improvements.

<table>
<tr>
<td width="50%"><img src="assets/screenshots/home-feed.png" alt="YouTube on Apple CarPlay: native home feed with a responsive three-column video grid"><br><strong>Browse</strong> — a feed that fits the screen.</td>
<td width="50%"><img src="assets/screenshots/watch-page.png" alt="Native YouTube CarPlay player with video on the left and a Mix playlist on the right"><br><strong>Watch</strong> — video and playlist side by side.</td>
</tr>
</table>

> For use while parked. Follow local laws and your vehicle's restrictions. This is an experimental, independent project—not an official Google or Apple app.

## Can I install it?

**This is currently a project for people comfortable with iOS app signing, or with help from a developer. There is no one-tap installation or ready-to-install IPA here.**

You need:

| Requirement | In plain language |
| --- | --- |
| Compatible iPhone software | Intended range: **iOS 26.4–27.2**, experimental. The demonstrated device ran **iOS 27.0.1**; every version in the range has not been verified. |
| Compatible YouTube + YouMod app | Baseline: **YouTube 21.42.4 + YouMod 2.0.0**. Supply your own compatible decrypted IPA that you are authorized to modify. |
| CarPlay video capability | Your signing profile must authorize **`com.apple.developer.carplay-video`**. Ordinary sideloading alone does not supply this permission. |
| A Mac for building | Xcode, an iPhoneOS SDK, and Python 3.9 or later. |
| Your own signing setup | A matching App ID, certificate, provisioning profile, and registered iPhone. |

**New to this?** Start with the [step-by-step build and installation guide](docs/BUILD.md). The [release build kit](https://github.com/sa4hnd/YouDash/releases) contains source and a compiled integration module—not the complete YouTube app. A developer can help you package and sign it using your own authorized input and capabilities.

**Already developing iOS apps?** Use the quick start below.

## Build YouDash

```sh
git clone https://github.com/sa4hnd/YouDash.git
cd YouDash
python3 -m venv .venv
source .venv/bin/activate
python3 -m pip install -r requirements-build.txt
python3 scripts/build_carplay.py --compile-only
```

This builds `build/YouTubeCarPlay.dylib`. To package your own compatible input and install on your registered iPhone:

```sh
python3 scripts/build_carplay.py \
  --ipa /path/to/YouMod.ipa \
  --profile /path/to/your.mobileprovision \
  --bundle-id com.example.youtubecar \
  --device YOUR_DEVICE_UDID
```

Use your own bundle ID, profile, and device ID. For an **unsigned IPA**, replace `--profile` and `--device` with `--unsigned`. The builder checks the input, compiles the module, injects it, and packages the result. The signed path also installs and launches the app.

**[Full build guide →](docs/BUILD.md)** — prerequisites, unsigned export, signing, module updates, and troubleshooting.

**No Mac?** [Build on GitHub Actions →](docs/GITHUB_ACTIONS.md). It uses a macOS runner, takes your input IPA and signing material from repository secrets, and uploads an encrypted IPA.

### About the CarPlay entitlement

Your provisioning profile must permit:

```xml
<key>com.apple.developer.carplay-video</key>
<true/>
```

Adding this text to a file does not grant the capability. Obtain the required capability through an authorized Apple developer provisioning setup. The project does not supply signing credentials or bypass entitlement authorization. Vehicle and OS support are also required.

## How it works

We made the native YouTube app work on CarPlay by adding a small native integration module:

1. **Connect the app to a CarPlay window.** Preserve YouTube's original phone initialization, then transfer its initialized native interface to the authorized car display.
2. **Adapt the layout.** Apply viewport scaling, safe-area handling, responsive feed columns, and a landscape video/queue layout. This is custom responsive behavior, rather than a blanket iPad-mode switch.
3. **Add car-screen input.** An on-screen keyboard sends text to the app's native input fields.
4. **Keep YouTube's player and YouMod.** Playback continues through the existing YouTube engine. Ad blocking comes from YouMod; the CarPlay module handles the display integration.
5. **Return to the phone on disconnect.** Restore the app surface to its original phone window.

The integration uses Objective-C runtime hooks and a Swift keyboard, packaged as `YouTubeCarPlay.dylib`. The build scripts add CarPlay scene configuration and inject the module into the user-supplied app.

**[Architecture and source walkthrough →](docs/ARCHITECTURE.md)**

## Frequently asked questions

**Is it open source?**

Yes—the CarPlay integration and build tools are GPL-3.0, and an attributed YouMod source snapshot is included. Google's proprietary YouTube app is not open source and is not included. See [LICENSE](LICENSE) and [NOTICE.md](NOTICE.md).

**Does it block ads?**

Yes, through the included YouMod integration in the compatible input app. Ad blocking worked in the development build. YouTube changes can affect it, so it is not a permanent guarantee for every input version or account.

**Does it work on every car or iPhone?**

Compatibility is experimental. Screen sizes, OS versions, head units, app versions, and signing capabilities matter. The iOS 17 module deployment target is only a compilation floor; it does not mean CarPlay video works on iOS 17. See [compatibility](docs/COMPATIBILITY.md).

**Why does the app report a different YouTube version?**

The baseline executable is 21.42.4; it reports 21.45.4 as a playback compatibility workaround. That resolved the observed playback failure during development. It does not upgrade YouTube or guarantee that all playback errors are fixed.

**What should I download?**

Use the [source repository](https://github.com/sa4hnd/YouDash) for current code. [Releases](https://github.com/sa4hnd/YouDash/releases) provide versioned build kits and modules. You still need your own compatible app input and authorized signing setup.

## Help improve it

If you want to follow the project, **star the repository**. Useful bug reports and pull requests help make it work on more displays.

For an issue, include your actual YouTube version, iOS version, display dimensions, and steps to reproduce it. Remove account names, notifications, device IDs, and signing files from attachments.

[Contributing](CONTRIBUTING.md) · [Report a bug](https://github.com/sa4hnd/YouDash/issues) · [Security](SECURITY.md) · [Changelog](CHANGELOG.md) · [Release guide](docs/RELEASING.md)

## About the name

**YouDash** is the project name. **Native YouTube for Apple CarPlay** describes what it does. Previously shared `sa4hnd/YouTube-Car` links redirect to this repository.

## Credits

CarPlay integration by **[Sehind Hemzani](https://github.com/sa4hnd)**.

Built on **[YouMod](https://github.com/Tonwalter888/YouMod)** and the work of its contributors. Original upstream notices and credits are preserved; see [NOTICE.md](NOTICE.md) for dependencies and provenance.

YouTube and Apple CarPlay are trademarks of their respective owners. This project is not affiliated with Google or Apple.

<p align="center">
  <img src="assets/kurdistan-flag.svg" width="48" height="32" alt="Flag of Kurdistan">
</p>
