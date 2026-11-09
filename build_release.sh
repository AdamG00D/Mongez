#!/usr/bin/env bash
# Builds release artifacts for Mongez.
#   ./build_release.sh          -> APK (universal + split per ABI)
#   ./build_release.sh aab      -> Android App Bundle for Google Play
#
# Toolchains: uses flutter / java from PATH. If they live elsewhere, set
# TOOLCHAINS to a folder containing flutter/, android-sdk/ and jdk-*.
# Signing: android/key.properties (see key.properties.example). Set
# ALLOW_DEBUG_SIGNING=1 to build without it (debug-signed, for testing only).
set -euo pipefail

TOOLCHAINS="${TOOLCHAINS:-$HOME/Downloads/Files/toolchains}"
if [[ -d "$TOOLCHAINS" ]]; then
  if [[ -z "${ANDROID_HOME:-}" && -d "$TOOLCHAINS/android-sdk" ]]; then
    export ANDROID_HOME="$TOOLCHAINS/android-sdk"
  fi
  if [[ -z "${JAVA_HOME:-}" ]] && compgen -G "$TOOLCHAINS/jdk-*" >/dev/null; then
    JAVA_HOME="$(ls -d "$TOOLCHAINS"/jdk-* | head -n1)"
    export JAVA_HOME
  fi
  [[ -d "$TOOLCHAINS/flutter/bin" ]] && export PATH="$TOOLCHAINS/flutter/bin:$PATH"
fi
[[ -n "${ANDROID_HOME:-}" ]] && export ANDROID_SDK_ROOT="$ANDROID_HOME"
[[ -n "${JAVA_HOME:-}" ]] && export PATH="$JAVA_HOME/bin:$PATH"

command -v flutter >/dev/null || { echo "flutter not found on PATH (or set TOOLCHAINS)." >&2; exit 1; }

cd "$(dirname "$0")"

if [[ ! -f android/key.properties ]]; then
  if [[ "${ALLOW_DEBUG_SIGNING:-0}" == "1" ]]; then
    echo "WARNING: android/key.properties missing - building with the debug key." >&2
  else
    echo "android/key.properties is missing (release signing key)." >&2
    echo "Copy android/key.properties.example, or run with ALLOW_DEBUG_SIGNING=1." >&2
    exit 1
  fi
fi

flutter pub get
flutter analyze
flutter test

if [[ "${1:-apk}" == "aab" ]]; then
  flutter build appbundle --release
  echo "AAB: build/app/outputs/bundle/release/app-release.aab"
else
  flutter build apk --release
  flutter build apk --release --split-per-abi
  echo "Universal APK : build/app/outputs/flutter-apk/app-release.apk"
  echo "Per-ABI APKs  : build/app/outputs/flutter-apk/app-*-release.apk"
fi
