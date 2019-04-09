#!/bin/bash

set -e

mkdir -p $DIR/src && cd $DIR
#rm -rf $DIR/src/out/Default
mkdir -p $DIR/src/out/Default


fetch --nohooks chromium || true
cd $DIR/src
echo "target_os = [ 'android' ]" >> ../.gclient
gclient sync --with_branch_heads --jobs 6
build/install-build-deps-android.sh
build/linux/sysroot_scripts/install-sysroot.py --all
gclient runhooks


cat << EOF > out/Default/args.gn

target_os = "android"
target_cpu = "arm64"

is_debug = false
remove_webcore_debug_symbols=true

use_lld = true # experimental

is_official_build = true
is_component_build = false
enable_resource_whitelist_generation = false
symbol_level = 0

ffmpeg_branding = "Chrome"
proprietary_codecs = true

android_channel = "stable"
android_default_version_name = "$VER"
android_default_version_code = "$REV"
EOF

gn gen out/Default

ninja -C out/Default/ monochrome_public_apk

