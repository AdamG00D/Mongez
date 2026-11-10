#!/usr/bin/env bash
# README banner and GitHub social preview (1280x640), from assets/icon.png and
# the store screenshots. Needs ImageMagick 7 with Pango.
#   docs/banner.png
set -euo pipefail
cd "$(dirname "$0")/.."
SHOTS=fastlane/metadata/android/ar/images/phoneScreenshots
OUT=docs/banner.png
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
mkdir -p docs

cat > "$TMP/fonts.conf" <<XML
<?xml version="1.0"?>
<fontconfig><dir>$PWD/fonts</dir><include ignore_missing="yes">/etc/fonts/fonts.conf</include><cachedir>$TMP/cache</cachedir></fontconfig>
XML
export FONTCONFIG_FILE="$TMP/fonts.conf"

# Rounded corners for a square/rect image: round <in> <w> <h> <radius> <out>
round() {
  magick "$1" -resize "${2}x${3}^" -gravity North -extent "${2}x${3}" \
    \( -size "${2}x${3}" xc:black -fill white \
       -draw "roundrectangle 0,0 $(($2 - 1)),$(($3 - 1)) $4,$4" \) \
    -alpha off -compose CopyOpacity -composite "$5"
}
# Phone: screenshot in a dark rounded frame with a soft shadow.
phone() { # in out
  round "$1" 236 472 30 "$TMP/scr.png"
  magick -size 252x488 xc:none -fill '#151a3d' -draw "roundrectangle 0,0 251,487 38,38" \
    "$TMP/scr.png" -gravity Center -composite "$TMP/frame.png"
  magick "$TMP/frame.png" \( +clone -background '#0b0f30' -shadow 55x18+0+16 \) \
    +swap -background none -layers merge +repage "$2"
}
phone "$SHOTS/6_dark.png" "$TMP/back.png"
phone "$SHOTS/1_tasks.png" "$TMP/front.png"
magick "$TMP/back.png" -background none -rotate -8 "$TMP/back.png"

round assets/icon.png 132 132 33 "$TMP/icon.png"
magick "$TMP/icon.png" \( +clone -background '#10143c' -shadow 45x12+0+8 \) \
  +swap -background none -layers merge +repage "$TMP/icon.png"

text() { # size weight markup out [color]
  magick -background none -define pango:align=right \
    pango:"<span font_family='Cairo' font_weight='$2' font_size='${1}pt' foreground='${5:-white}'>$3</span>" "$4"
}
text 84 900 'مُنجز' "$TMP/title.png"
text 25 700 'خطّط يومك · تابع أهدافك · اعرف وقتك' "$TMP/tag.png"
text 16 600 'بدون حساب · بدون إعلانات · بدون إنترنت' "$TMP/sub.png"
text 15 700 'مجاني ومفتوح المصدر لأندرويد' "$TMP/pill_text.png" '#3b3f9e'
pw=$(($(magick identify -format %w "$TMP/pill_text.png") + 48))
magick -size "${pw}x50" xc:none -fill white -draw "roundrectangle 0,0 $((pw - 1)),49 25,25" \
  "$TMP/pill_text.png" -gravity Center -composite "$TMP/pill.png"

magick -size 1280x640 -define gradient:angle=115 gradient:'#6D5DFC-#14C2D6' \
  \( -size 1280x640 xc:none -fill 'rgba(255,255,255,0.10)' \
     -draw "circle 150,610 150,330" -draw "circle 1180,10 1180,190" \) -composite \
  "$TMP/back.png" -gravity NorthWest -geometry +70+52 -composite \
  "$TMP/front.png" -gravity NorthWest -geometry +250+52 -composite \
  "$TMP/icon.png" -gravity NorthEast -geometry +72+92 -composite \
  "$TMP/title.png" -gravity NorthEast -geometry +240+70 -composite \
  "$TMP/tag.png" -gravity NorthEast -geometry +80+268 -composite \
  "$TMP/sub.png" -gravity NorthEast -geometry +80+340 -composite \
  "$TMP/pill.png" -gravity NorthEast -geometry +80+420 -composite \
  -alpha off -depth 8 -strip "$OUT"
echo "Wrote $OUT"
