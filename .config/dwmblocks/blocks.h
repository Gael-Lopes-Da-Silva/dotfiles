//Modify this file to change what commands output to your statusbar, and recompile using the make command.
static const Block blocks[] = {
	/*Icon*/  /*Command*/		                                /*Update Interval*/  /*Update Signal*/
	{"",      "echo test",         1,                   0},
	/* {"",      "$HOME/.config/dwmblocks/scripts/rec.sh",         1,                   0}, */
	/* {"",      "$HOME/.config/dwmblocks/scripts/volume.sh",      1,                   0}, */
	/* {"",      "$HOME/.config/dwmblocks/scripts/brightness.sh",  1,                   0}, */
	/* {"",      "$HOME/.config/dwmblocks/scripts/battery.sh",     1,                   0}, */
	/* {"",      "$HOME/.config/dwmblocks/scripts/date.sh",        1,                   0}, */
	/* {"",      "$HOME/.config/dwmblocks/scripts/time.sh",        1,                   0}, */
};

//sets delimiter between status commands. NULL character ('\0') means no delimiter.
static char delim[] = "|";
static unsigned int delimLen = 5;