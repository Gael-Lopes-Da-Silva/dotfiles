//Modify this file to change what commands output to your statusbar, and recompile using the make command.
static const Block blocks[] = {
	/*Icon*/  /*Command*/		                                         /*Update Interval*/  /*Update Signal*/
	{"",      "$HOME/.config/suckless/dwmblocks/scripts/rec",            1,                   0},
	{"",      "$HOME/.config/suckless/dwmblocks/scripts/volume",         1,                   0},
	{"",      "$HOME/.config/suckless/dwmblocks/scripts/brightness",     1,                   0},
	{"",      "$HOME/.config/suckless/dwmblocks/scripts/battery",        1,                   0},
	{"",      "$HOME/.config/suckless/dwmblocks/scripts/date",           1,                   0},
	{"",      "$HOME/.config/suckless/dwmblocks/scripts/time",           1,                   0},
};

//sets delimiter between status commands. NULL character ('\0') means no delimiter.
static char delim[] = "|";
static unsigned int delimLen = 5;
