"""Run native window-transfer regression checks in a booted iOS simulator.

Usage: python3 tests/run_native_surface.py SIMULATOR_UDID [--fallback-only]
"""
import pathlib
import plistlib
import subprocess
import sys
import tempfile

fallback_only = "--fallback-only" in sys.argv[2:]
harness = "native_fallback_harness.m" if fallback_only else "native_surface_harness.m"
marker = "NATIVE_FALLBACK_TESTS_PASSED" if fallback_only else "NATIVE_SURFACE_TESTS_PASSED"
root = pathlib.Path(__file__).resolve().parents[1]
def run(*args):
    result = subprocess.run([str(a) for a in args], capture_output=True, text=True)
    if result.returncode:
        sys.stderr.write(result.stdout + result.stderr)
        result.check_returncode()
    return result
with tempfile.TemporaryDirectory(prefix="youmod-surface-test-") as temp:
    app = pathlib.Path(temp) / "SurfaceTests.app"
    app.mkdir()
    sdk = run("xcrun", "--sdk", "iphonesimulator", "--show-sdk-path").stdout.strip()
    run("xcrun", "clang", "-target", "arm64-apple-ios17.0-simulator", "-isysroot", sdk,
        "-fobjc-arc", "-I", root / "CarPlay", "-framework", "UIKit", "-framework", "CarPlay",
        "-framework", "Foundation", "-framework", "CoreGraphics", root / "CarPlay/YCPNative.m", root / "CarPlay/YCPResponsiveLayout.m", root / "tests" / harness,
        "-o", app / "SurfaceTests")
    (app / "Info.plist").write_bytes(plistlib.dumps({
        "CFBundleIdentifier": "io.github.youtubecar.surface-tests", "CFBundleExecutable": "SurfaceTests",
        "CFBundleName": "SurfaceTests", "CFBundlePackageType": "APPL", "CFBundleVersion": "1",
        "CFBundleShortVersionString": "1", "MinimumOSVersion": "17.0",
        "UIDeviceFamily": [1], "UILaunchScreen": {},
    }))
    run("codesign", "--force", "--sign", "-", app)
    run("xcrun", "simctl", "install", sys.argv[1], app)
    result = run("xcrun", "simctl", "launch", "--console", "--terminate-running-process", sys.argv[1], "io.github.youtubecar.surface-tests")
    output = result.stdout + result.stderr
    if marker not in output:
        raise RuntimeError(output)
    print("Native fallback regression checks passed" if fallback_only else "Native surface regression checks passed: startup, transfer, navigation, traits, replacement, restoration, reconnect")
