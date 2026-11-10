#!/usr/bin/env bash
# Store listing graphics from assets/icon.png (needs ImageMagick 7 with Pango):
#   fastlane/metadata/android/ar/images/icon.png            512x512
#   fastlane/metadata/android/ar/images/featureGraphic.png  1024x500
set -euo pipefail
cd "$(dirname "$0")/.."
OUT=fastlane/metadata/android/ar/images
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
mkdir -p "$OUT"

# Let Pango find the bundled Cairo font.
cat > "$TMP/fonts.conf" <<XML
<?xml version="1.0"?>
<fontconfig><dir>$PWD/fonts</dir><include ignore_missing="yes">/etc/fonts/fonts.conf</include><cachedir>$TMP/cache</cachedir></fontconfig>
XML
export FONTCONFIG_FILE="$TMP/fonts.conf"

magick assets/icon.png -resize 512x512 -depth 8 -strip "$OUT/icon.png"

# Rounded icon with a soft shadow.
magick assets/icon.png -resize 250x250 \
  \( +clone -alpha extract -fill black -colorize 100 -fill white \
     -draw "roundrectangle 0,0 249,249 62,62" \) \
  -alpha off -compose CopyOpacity -composite "$TMP/icon.png"
magick "$TMP/icon.png" \( +clone -background '#10143c' -shadow 45x14+0+10 \) \
  +swap -background none -layers merge +repage "$TMP/icon_shadow.png"

text() { # size weight markup -> file
  magick -background none -define pango:align=right \
    pango:"<span font_family='Cairo' font_weight='$2' font_size='${1}pt' foreground='white'>$3</span>" "$4"
}
text 78 900 'مُنجز' "$TMP/title.png"
text 23 700 'خطّط يومك · تابع أهدافك · اعرف وقتك' "$TMP/tag.png"
text 15 600 'بدون حساب · بدون إعلانات · بدون إنترنت' "$TMP/sub.png"

magick -size 1024x500 -define gradient:angle=115 gradient:'#6D5DFC-#14C2D6' \
  \( -size 1024x500 xc:none -fill 'rgba(255,255,255,0.10)' \
     -draw "circle 120,470 120,250" -draw "circle 930,20 930,170" \) -composite \
  "$TMP/icon_shadow.png" -gravity East -geometry +60+0 -composite \
  "$TMP/title.png" -gravity NorthEast -geometry +370+95 -composite \
  "$TMP/tag.png" -gravity NorthEast -geometry +370+275 -composite \
  "$TMP/sub.png" -gravity NorthEast -geometry +370+345 -composite \
  -alpha off -depth 8 -strip "$OUT/featureGraphic.png"
echo "Wrote $OUT/icon.png and $OUT/featureGraphic.png"
