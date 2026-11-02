#!/usr/bin/env bash
# Build an isolated preview; never compile or modify the incomplete root app.
set -euo pipefail

PREVIEW_SOURCE="$(cd "$(dirname "$0")/.." && pwd)"
if [[ "$(uname -s)" != Darwin ]]; then
  echo 'An iOS device build requires macOS and Xcode. Use the iOS preview GitHub Actions job.' >&2
  exit 1
fi
for command in flutter xcodebuild python3 zip shasum; do
  command -v "$command" >/dev/null || { echo "Missing command: $command" >&2; exit 1; }
done
xcodebuild -version
flutter --version

mkdir -p "${1:-$PREVIEW_SOURCE/dist}"
PREVIEW_OUTPUT="$(cd "${1:-$PREVIEW_SOURCE/dist}" && pwd)"
PREVIEW_WORK="$(mktemp -d "${TMPDIR:-/tmp}/wenku8-preview.XXXXXX")"
trap 'rm -rf "$PREVIEW_WORK"' EXIT
PREVIEW_APP="$PREVIEW_WORK/app"

flutter create --empty --platforms=ios --org=dev.quiteqa \
  --project-name=wenku8_preview --no-pub "$PREVIEW_APP"
cp "$PREVIEW_SOURCE/pubspec.yaml" "$PREVIEW_APP/pubspec.yaml"
cp -R "$PREVIEW_SOURCE/lib/." "$PREVIEW_APP/lib/"
# Discard the generated counter-app checks and lint-package include: this
# preview has its own entry and deliberately only SDK/runtime dependencies.
rm -rf "$PREVIEW_APP/test"
cat > "$PREVIEW_APP/analysis_options.yaml" <<'YAML'
analyzer:
  exclude:
    - build/**
YAML
/usr/libexec/PlistBuddy -c 'Set :CFBundleDisplayName 文库预览' "$PREVIEW_APP/ios/Runner/Info.plist"
# Keep the repository's existing branding when it is available.
PREVIEW_ICON="$PREVIEW_SOURCE/../assets/branding/app-icon.png"
if [[ -f "$PREVIEW_ICON" ]]; then
  python3 - "$PREVIEW_ICON" "$PREVIEW_APP/ios/Runner/Assets.xcassets/AppIcon.appiconset" <<'PY'
import json, pathlib, subprocess, sys
source, folder = sys.argv[1], pathlib.Path(sys.argv[2])
manifest = json.loads((folder / 'Contents.json').read_text())
for entry in manifest['images']:
    if 'filename' not in entry:
        continue
    pixels = round(float(entry['size'].split('x')[0]) * float(entry['scale'].rstrip('x')))
    subprocess.run(['sips', '-z', str(pixels), str(pixels), source,
                    '--out', str(folder / entry['filename'])], check=True, capture_output=True)
PY
fi

cd "$PREVIEW_APP"
flutter pub get
# Format the staged copy, keeping the submitted source untouched.
dart format lib
flutter analyze --fatal-infos
flutter build ios --release --no-codesign

PREVIEW_BUNDLE="$PREVIEW_APP/build/ios/iphoneos/Runner.app"
[[ -d "$PREVIEW_BUNDLE" ]] || { echo 'Runner.app was not produced' >&2; exit 1; }
# An IPA must contain a device binary under Payload/, not a simulator build.
file "$PREVIEW_BUNDLE/Runner"
/usr/bin/xcrun vtool -show-build "$PREVIEW_BUNDLE/Runner" | tee "$PREVIEW_OUTPUT/platform.txt"
grep -Eq 'platform[[:space:]]+IOS$' "$PREVIEW_OUTPUT/platform.txt"
mkdir -p "$PREVIEW_WORK/package/Payload"
cp -R "$PREVIEW_BUNDLE" "$PREVIEW_WORK/package/Payload/Runner.app"
cd "$PREVIEW_WORK/package"
zip -qry -y "$PREVIEW_OUTPUT/Wenku8-Preview-unsigned.ipa" Payload
unzip -tq "$PREVIEW_OUTPUT/Wenku8-Preview-unsigned.ipa"
cd "$PREVIEW_OUTPUT"
shasum -a 256 Wenku8-Preview-unsigned.ipa > SHA256SUMS.txt
printf '%s\n' 'Unsigned UI preview. Sign with your own Apple identity before installing.' > INSTALL.txt
printf '%s\n' "IPA: $PREVIEW_OUTPUT/Wenku8-Preview-unsigned.ipa"
