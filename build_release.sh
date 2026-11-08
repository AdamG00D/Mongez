#!/usr/bin/env bash
# Builds signed release artifacts for Mongez.
#   ./build_release.sh          -> APK (split per ABI + universal)
#   ./build_release.sh aab      -> Android App Bundle for Google Play
set -euo pipefail

TOOLCHAINS="${TOOLCHAINS:-$HOME/Downloads/Files/toolchains}"
export ANDROID_HOME="${ANDROID_HOME:-$TOOLCHAINS/android-sdk}"
export ANDROID_SDK_ROOT="$ANDROID_HOME"
export JAVA_HOME="${JAVA_HOME:-$(ls -d "$TOOLCHAINS"/jdk-* | head -n1)}"
export PATH="$TOOLCHAINS/flutter/bin:$JAVA_HOME/bin:$PATH"

cd "$(dirname "$0")"

if [[ ! -f android/key.properties ]]; then
  echo "android/key.properties is missing (release signing key). Aborting." >&2
  exit 1
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
