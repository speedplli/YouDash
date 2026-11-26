# Compatibility and known limits

## Intended OS range

The intended / reported compatibility range is **iOS 26.4–27.2**. This is experimental, not a claim that every release in the range has been tested. Versions below 26.4 and above 27.2 are outside this stated range. The observed device baseline below is the narrower evidence available.

## Demonstrated baseline

Actual YouTube 21.42.4 + YouMod 2.0.0, reporting 21.45.4, with the native YouTube player and this CarPlay module. UI and playback success were reported on a development iPhone running iOS 27.0.1 with several CarPlay display profiles. This is not certification for every head unit or every account.

The source targets iOS 17.0. A compilation target is not a promise that every target OS supports the required drawable CarPlay scene, entitlement, or vehicle behavior.

| Area | Behavior / limitation |
| --- | --- |
| Native phone scene | Preserved rather than replaced with a guessed initializer |
| Display sizes | Scale derives from the safe viewport; landscape supports split watch layout |
| CarPlay routing | Requires an authorized drawable window; templates alone cannot show arbitrary native views |
| Playback | Uses YouTube's existing engine; service behavior may vary by account/version |
| Reported version | 21.45.4 workaround; actual executable stays 21.42.4 |
| App updates | May rename private classes/selectors or alter layouts; compatibility is not automatic |
| Input | Native fields need to expose standard text-input APIs |
| Optional tweaks | Removed by default to reduce conflicts |
| Installation | Appropriate personal signing and capabilities required |

## CarPlay Simulator profiles and iOS 27.3 beta

The development setup used an iPhone running **iOS 27.0.1**, **Xcode 27.2**, and Apple's standalone **CarPlay Simulator**, including duplicated/custom display configurations. The exact standalone simulator build number was not recorded.

**iOS 27.3 beta is unverified and outside the stated intended range.** Issue [#3](https://github.com/sa4hnd/YouDash/issues/3) reports a template scene connecting without a drawable window on that version. This is not yet a confirmed OS regression.

For that report, the maintainer recommends trying a standard simulator configuration without video playback enabled, or duplicating `Standard Video Playback` and connecting through the duplicate instead of the built-in preset. These are troubleshooting suggestions, not a verified fix on iOS 27.3.

`Template connected: window=none` without a subsequent `Window connected` entry means the integration has received no drawable car window. A Home-screen icon or Now Playing controls do not establish that the OS has delivered a window capable of hosting the native interface. The integration cannot create entitlement authorization or head-unit support by itself.

## Playback error 14

“Something went wrong. Refresh and try again later” is a generic playback failure. Reloading on every failure can create an interruption loop; it does not repair the cause. In the development session, restoring native request-signal/ad-coordinator methods did not fix it and introduced ads, so that experiment was reverted. Incognito also failed. Reporting version 21.45.4 was then observed to resolve playback on that device.

These are observations, not a guarantee. Upstream reports remain relevant:

- [YouMod #172 — playback stops during viewing](https://github.com/Tonwalter888/YouMod/issues/172)
- [YouMod #86 — playback-fix failures and error 14](https://github.com/Tonwalter888/YouMod/issues/86)
- [uYouEnhanced #903 — version-related workaround discussion](https://github.com/arichornlover/uYouEnhanced/issues/903)
- [YTLite #364 — mixed results across versions and configurations](https://github.com/dayanch96/YTLite/issues/364)

An AVPlayer-backend replacement was considered but **not included** in this baseline. It is not necessary to build this project.

## Report a useful issue

Include actual and reported versions, OS version, viewport dimensions, whether the issue affects phone/car/both, and exact reproduction steps. A cropped screenshot may help, but remove account names, notifications, location, and unrelated desktop content. Do not upload your provisioning profile, account state, raw app container, or unreviewed logs.

## Investigation of issue #3 (November 21, 2026)

The report establishes that iOS connected a template scene without a drawable
window. It does not establish an iOS 27.3 regression: the same binary/profile
needs an A/B test on the earlier OS and the same simulator configuration.

Apple's [WWDC26 CarPlay session](https://developer.apple.com/videos/play/wwdc2026/212/)
describes video apps as a CarPlay-template browsing interface with AirPlay video
streaming in supported vehicles. The video entitlement is not a promise of a
custom UIKit window. The SDK's `CPSessionConfiguration.supportsVideoPlayback`
indicates vehicle video support, not the availability of an arbitrary drawable
scene or permission to play video at a particular moment.

This integration instead waits for a drawable scene and moves YouTube's native
view-controller tree into it. An Info.plist scene declaration registers a
handler; it does not force iOS to create that scene. Changing scene class names,
retrying phone startup, or adding unauthorized entitlements is not a supported
fix for an absent window. A supported template browser and AirPlay playback
adapter would be a separate implementation, with device validation required.

The local mitigation makes the missing-window screen explicit, logs only the
connected scene roles/classes, and refreshes the template when a window arrives
or disappears. It does **not** claim to restore video or solve the reported OS
compatibility problem. Native harness coverage includes template-only startup,
both connection arrival orders, late window arrival, window loss, stale window
disconnects, and restoration of the phone UI. A harness-created window tests our
lifecycle handling, not whether a real CarPlay session will supply that window.

For device investigation after approval, compare the same signed IPA on the
reported and baseline OS versions using the same supported simulator profile.
Record whether the template callback includes a window, whether a separate
window scene connects, and `supportsVideoPlayback`. Test actual video playback
only while parked and let the system/vehicle enforce playback availability.

Validation on the local iOS 26.2 simulator: the focused fallback harness passes
(`tests/run_native_surface.py SIMULATOR_UDID --fallback-only`), and the native
module compiles against the iOS 27.2 SDK. All five packaging tests pass. The
existing full surface harness fails its tablet-layout-trait assertion on both
unchanged upstream commit `47041e9` and this patch. That unrelated baseline
failure remains unresolved; full native regression coverage is not claimed.
No iOS 27.3/physical CarPlay playback test has been performed.
