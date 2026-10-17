#!/bin/sh
# Print "token<TAB>name<TAB>path" for each icon name.
# Prefer a theme PNG. SVG icons are rasterized: Qt paints feColorMatrix
# filters and enable-background as an opaque black square.
token=$1
cache="${XDG_CACHE_HOME:-$HOME/.cache}/shell-icons"
mkdir -p "$cache"

rsvg=""
if command -v rsvg-convert >/dev/null 2>&1; then
	rsvg=$(command -v rsvg-convert)
else
	marker="$cache/.rsvg-convert"
	if [ -f "$marker" ]; then
		cand=$(cat "$marker")
		[ -x "$cand" ] && rsvg=$cand
	fi
	if [ -z "$rsvg" ]; then
		cand=$(find /nix/store -maxdepth 3 -type f -name rsvg-convert -print -quit 2>/dev/null)
		if [ -n "$cand" ] && [ -x "$cand" ]; then
			printf '%s\n' "$cand" > "$marker"
			rsvg=$cand
		fi
	fi
fi

rasterize() {
	src=$1
	dest=$2
	[ -n "$rsvg" ] || return 1
	tmp="$dest.tmp"
	if "$rsvg" -w 256 -h 256 "$src" -o "$tmp"; then
		mv "$tmp" "$dest"
		return 0
	fi
	rm -f "$tmp"
	return 1
}

printf '%s\n' "$2" | while IFS= read -r name; do
	[ -n "$name" ] || continue
	found=""
	if [ -f "$name" ]; then
		case $name in
			*.svg|*.svgz)
				png="$cache/$(basename "$name" | sed 's/\.svgz\?$//').png"
				if [ ! -s "$png" ] || [ "$name" -nt "$png" ]; then
					rasterize "$name" "$png" && found=$png
				else
					found=$png
				fi
				[ -n "$found" ] || found=$name
				;;
			*)
				found=$name
				;;
		esac
	else
		oldifs=$IFS
		IFS=:
		for dir in $XDG_DATA_DIRS; do
			[ -n "$dir" ] || continue
			for size in 512x512 512x512@2 256x256 256x256@2 128x128 128x128@2 64x64 48x48 32x32; do
				png="$dir/icons/hicolor/$size/apps/$name.png"
				if [ -f "$png" ]; then
					found=$png
					break
				fi
			done
			[ -n "$found" ] && break
			svg="$dir/icons/hicolor/scalable/apps/$name.svg"
			if [ -f "$svg" ]; then
				png="$cache/$name.png"
				if [ ! -s "$png" ] || [ "$svg" -nt "$png" ]; then
					if rasterize "$svg" "$png"; then
						found=$png
					else
						clean="$cache/$name.svg"
						if [ ! -f "$clean" ] || [ "$svg" -nt "$clean" ]; then
							sed -E 's/enable-background:[^;"]*//g' "$svg" > "$clean"
						fi
						found=$clean
					fi
				else
					found=$png
				fi
				break
			fi
			png="$dir/pixmaps/$name.png"
			if [ -f "$png" ]; then
				found=$png
				break
			fi
		done
		IFS=$oldifs
	fi
	printf '%s\t%s\t%s\n' "$token" "$name" "$found"
done
