#!/usr/bin/env bash
set -euo pipefail

target="${1:-all}"
brand_icon="${2:-assets/branding/pulse_chart_icon.png}"

if [[ ! -f "$brand_icon" ]]; then
  echo "Brand icon not found: $brand_icon" >&2
  exit 1
fi

brand_directory="$(dirname "$brand_icon")"

apply_web_branding() {
  mkdir -p web/icons

  cp "$brand_directory/web/favicon.png" web/favicon.png
  cp "$brand_directory/web/Icon-192.png" web/icons/Icon-192.png
  cp "$brand_directory/web/Icon-512.png" web/icons/Icon-512.png

  cat > web/index.html <<'HTML'
<!DOCTYPE html>
<html>
<head>
  <base href="$FLUTTER_BASE_HREF">
  <meta charset="UTF-8">
  <meta content="IE=Edge" http-equiv="X-UA-Compatible">
  <meta name="description" content="Pulse Chart - real-time market chart workspace.">
  <meta name="theme-color" content="#17191d">
  <meta name="mobile-web-app-capable" content="yes">
  <meta name="apple-mobile-web-app-capable" content="yes">
  <meta name="apple-mobile-web-app-status-bar-style" content="black">
  <meta name="apple-mobile-web-app-title" content="Pulse Chart">
  <link rel="icon" type="image/png" href="favicon.png">
  <link rel="apple-touch-icon" href="icons/Icon-192.png">
  <link rel="manifest" href="manifest.json">
  <title>Pulse Chart</title>
</head>
<body>
  <script src="flutter_bootstrap.js" async></script>
</body>
</html>
HTML

  cat > web/manifest.json <<'JSON'
{
  "name": "Pulse Chart",
  "short_name": "Pulse Chart",
  "start_url": ".",
  "display": "standalone",
  "background_color": "#17191d",
  "theme_color": "#00de5a",
  "description": "Real-time market chart workspace.",
  "orientation": "any",
  "icons": [
    {
      "src": "icons/Icon-192.png",
      "sizes": "192x192",
      "type": "image/png",
      "purpose": "any maskable"
    },
    {
      "src": "icons/Icon-512.png",
      "sizes": "512x512",
      "type": "image/png",
      "purpose": "any maskable"
    }
  ]
}
JSON
}

apply_android_branding() {
  local manifest=android/app/src/main/AndroidManifest.xml
  sed -i.bak 's#@mipmap/ic_launcher#@mipmap/pulse_chart_icon#g' "$manifest"
  rm -f "$manifest.bak"

  while read -r density; do
    mkdir -p "android/app/src/main/res/mipmap-$density"
    cp "$brand_directory/android/mipmap-$density/pulse_chart_icon.png" \
      "android/app/src/main/res/mipmap-$density/pulse_chart_icon.png"
  done <<'DENSITIES'
mdpi
hdpi
xhdpi
xxhdpi
xxxhdpi
DENSITIES
}

case "$target" in
  web)
    apply_web_branding
    ;;
  android)
    apply_android_branding
    ;;
  all)
    apply_web_branding
    apply_android_branding
    ;;
  *)
    echo "Usage: $0 [web|android|all] [icon-path]" >&2
    exit 1
    ;;
esac
