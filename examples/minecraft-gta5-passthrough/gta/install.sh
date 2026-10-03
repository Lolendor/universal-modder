#!/bin/bash
# Install the passthrough into GTA V Legacy: ScriptHookV + its ASI loader, MCPassthrough.asi and
# ReShade with MCPassthrough.fx. Only adds files; `install.sh --remove` deletes exactly those.
# ReShade goes in as ReShade64.asi, loaded by the ASI loader: GTA loads the system dxgi.dll, so a ReShade dxgi.dll
# in the game folder never runs.
#   GTA_DIR   the folder with GTA5.exe (default: GTA V Legacy, Steam app 271590, found in your Steam libraries)
#   RUNTIME   ScriptHookV.dll, dinput8.dll, ReShade64.dll from fetch_deps.sh (default third_party/runtime)
#   BUILD     where build.sh put MCPassthrough.asi (default <PASSTHROUGH_WIN_DIR>\gta\build, C:\dev\passthrough\...)
#   FORCE=1   replace a dinput8.dll or ReShade64.asi that some other mod (or you) put there
set -e
HERE=$(cd "$(dirname "$0")" && pwd)
WIN=${PASSTHROUGH_WIN_DIR:-'C:\dev\passthrough'}
RUNTIME=${RUNTIME:-$HERE/third_party/runtime}
BUILD=${BUILD:-$(wslpath -u "$WIN\\gta\\build")}
FILES=(ScriptHookV.dll dinput8.dll MCPassthrough.asi ReShade64.asi ReShade.ini ReShadePreset.ini
	reshade-shaders/Shaders/MCPassthrough.fx reshade-shaders/Shaders/ReShade.fxh reshade-shaders/Shaders/ReShadeUI.fxh)

# the Steam libraries: the default ones and every other one listed in their libraryfolders.vdf
steam_libraries() {
	for steam in "/mnt/c/Program Files (x86)/Steam" "/mnt/c/Program Files/Steam"; do
		[ -d "$steam/steamapps" ] || continue
		echo "$steam"
		sed -n 's/^[[:space:]]*"path"[[:space:]]*"\(.*\)"/\1/p' "$steam/steamapps/libraryfolders.vdf" 2>/dev/null |
			sed 's/\\\\/\\/g' | while read -r p; do wslpath -u "$p"; done
	done
}
if [ -z "$GTA_DIR" ]; then
	while read -r lib; do
		acf="$lib/steamapps/appmanifest_271590.acf"
		[ -f "$acf" ] && GTA_DIR="$lib/steamapps/common/$(sed -n 's/^[[:space:]]*"installdir"[[:space:]]*"\(.*\)"/\1/p' "$acf")" && break
	done < <(steam_libraries)
fi
GTA=${GTA_DIR:?GTA V Legacy not found in your Steam libraries: set GTA_DIR to the folder with GTA5.exe}
case $GTA in [A-Za-z]:*) GTA=$(wslpath -u "$GTA") ;; esac

[ -f "$GTA/GTA5.exe" ] || { echo "GTA5.exe not found in: $GTA"; exit 1; }
if [ "$1" = "--remove" ]; then
	for f in "${FILES[@]}"; do rm -fv "$GTA/$f"; done
	rmdir "$GTA/reshade-shaders/Shaders" "$GTA/reshade-shaders" 2>/dev/null || true
	exit 0
fi
[ -f "$RUNTIME/ScriptHookV.dll" ] || { echo "fetch the runtime first: gta/fetch_deps.sh"; exit 1; }
[ -f "$BUILD/MCPassthrough.asi" ] || { echo "build it first: gta/build.sh"; exit 1; }
# another mod's ASI loader or ReShade stay unless FORCE=1 (--remove would delete them)
clash=
[ ! -f "$GTA/dinput8.dll" ] || cmp -s "$RUNTIME/dinput8.dll" "$GTA/dinput8.dll" || clash+=" dinput8.dll"
[ ! -f "$GTA/ReShade64.asi" ] || cmp -s "$RUNTIME/ReShade64.dll" "$GTA/ReShade64.asi" || clash+=" ReShade64.asi"
[ -z "$clash" ] || [ -n "$FORCE" ] || { echo "not replacing what is already in $GTA:$clash (FORCE=1 to replace)"; exit 1; }
cp -v "$RUNTIME/ScriptHookV.dll" "$RUNTIME/dinput8.dll" "$BUILD/MCPassthrough.asi" "$GTA/"
cp -v "$RUNTIME/ReShade64.dll" "$GTA/ReShade64.asi"
mkdir -p "$GTA/reshade-shaders/Shaders"
cp -v "$HERE/shaders/MCPassthrough.fx" "$HERE/third_party/ReShade.fxh" "$HERE/third_party/ReShadeUI.fxh" "$GTA/reshade-shaders/Shaders/"
if [ ! -f "$GTA/ReShade.ini" ]; then
	printf '[GENERAL]\r\nEffectSearchPaths=.\\reshade-shaders\\Shaders\\\r\nTextureSearchPaths=.\\reshade-shaders\\Textures\\\r\nPresetPath=.\\ReShadePreset.ini\r\nPreprocessorDefinitions=RESHADE_DEPTH_INPUT_IS_REVERSED=1,RESHADE_DEPTH_INPUT_IS_UPSIDE_DOWN=0,RESHADE_DEPTH_INPUT_IS_LOGARITHMIC=0,RESHADE_DEPTH_LINEARIZATION_FAR_PLANE=1000\r\n\r\n[OVERLAY]\r\nTutorialProgress=4\r\nShowClock=0\r\nShowFPS=0\r\n\r\n[SCREENSHOT]\r\nSavePath=.\\\r\n' > "$GTA/ReShade.ini"
fi
# the technique is always on; its McActive uniform (set by the add-on) keeps it a pure passthrough until
# Minecraft frames arrive
printf 'Techniques=MCPassthrough@MCPassthrough.fx\r\nTechniqueSorting=MCPassthrough@MCPassthrough.fx\r\n' > "$GTA/ReShadePreset.ini"
echo "installed into $GTA"
