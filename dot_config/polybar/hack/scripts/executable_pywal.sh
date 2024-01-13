#!/usr/bin/env bash

# Color files
PFILE="$HOME/.config/polybar/hack/colors.ini"
RFILE="$HOME/.config/polybar/hack/scripts/rofi/colors.rasi"

# Get colors
pywal_get() {
	wal -i "$1" -q -t
}

# Change colors
change_color() {
	# polybar
	sed -i -e "s/background = #.*/background = $BG/g" $PFILE
	sed -i -e "s/foreground = #.*/foreground = $FG/g" $PFILE
	sed -i -e "s/colour1 = #.*/colour1 = $C1/g" $PFILE
	sed -i -e "s/colour2 = #.*/colour2 = $C2/g" $PFILE
	sed -i -e "s/colour3 = #.*/colour3 = $C3/g" $PFILE
	sed -i -e "s/colour4 = #.*/colour4 = $C4/g" $PFILE
	sed -i -e "s/colour5 = #.*/colour5 = $C5/g" $PFILE
	sed -i -e "s/colour6 = #.*/colour6 = $C6/g" $PFILE
	sed -i -e "s/colour7 = #.*/colour7 = $C7/g" $PFILE
	sed -i -e "s/colour8 = #.*/colour8 = $C8/g" $PFILE
	sed -i -e "s/colour9 = #.*/colour9 = $C9/g" $PFILE
	sed -i -e "s/colour10 = #.*/colour10 = $C10/g" $PFILE
	sed -i -e "s/colour11 = #.*/colour11 = $C11/g" $PFILE
	sed -i -e "s/colour12 = #.*/colour12 = $C12/g" $PFILE
	sed -i -e "s/colour13 = #.*/colour13 = $C13/g" $PFILE
	sed -i -e "s/colour14 = #.*/colour14 = $C14/g" $PFILE
	sed -i -e "s/colour15 = #.*/colour15 = $C15/g" $PFILE

	# rofi
	cat > $RFILE <<- EOF
	/* colors */

	* {
	  al:    #00000000;
	  bg:    ${BG}FF;
	  ac:    ${C1}FF;
	  se:    ${C1}26;
	  fg:    ${FG}FF;
	}
	EOF
	
	polybar-msg cmd restart
}

# Main
if [[ -f "/home/zekea/.local/bin/wal" ]]; then
	if [[ "$1" ]]; then
		pywal_get "$1"

		# Source the pywal color file
		. "$HOME/.cache/wal/colors.sh"

		BG=`printf "%s\n" "$background"`
		FG=`printf "%s\n" "$foreground"`
		C1=`printf "%s\n" "$color1"`
		C2=`printf "%s\n" "$color2"`
		C3=`printf "%s\n" "$color3"`
		C4=`printf "%s\n" "$color4"`
		C5=`printf "%s\n" "$color5"`
		C6=`printf "%s\n" "$color6"`
		C7=`printf "%s\n" "$color7"`
		C8=`printf "%s\n" "$color8"`
		C9=`printf "%s\n" "$color9"`
		C10=`printf "%s\n" "$color10"`
		C11=`printf "%s\n" "$color11"`
		C12=`printf "%s\n" "$color12"`
		C13=`printf "%s\n" "$color13"`
		C14=`printf "%s\n" "$color14"`
		C15=`printf "%s\n" "$color15"`

		change_color
	else
		echo -e "[!] Please enter the path to wallpaper. \n"
		echo "Usage : ./pywal.sh path/to/image"
	fi
else
	echo "[!] 'pywal' is not installed."
fi
