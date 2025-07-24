// Function prototypes for components
char *rec_status(void);
char *volume_status(void);
char *brightness_status(void);
char *battery_status(void);
char *date_status(void);
char *time_status(void);

// Modify this file to change what commands output to your statusbar, and recompile using the make command.
static const Block blocks[] = {
	/*Icon*/    /*Function*/           /*Update Interval*/     /*Update Signal*/
	{"",        rec_status,            1,                      0},
	{"",        volume_status,         1,                      0},
	{"",        brightness_status,     1,                      0},
	{"",        battery_status,        1,                      0},
	{"",        date_status,           1,                      0},
	{"",        time_status,           1,                      0},
};

// Sets delimiter between status commands. NULL character ('\0') means no delimiter.
static char delim[] = "^c#474747^|^d^";
static unsigned int delimLen = 15;
