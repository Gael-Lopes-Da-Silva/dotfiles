#include<stdio.h>
#include<string.h>
#include<unistd.h>
#include<signal.h>
#ifndef NO_X
#include<X11/Xlib.h>
#endif
#ifdef __OpenBSD__
#define SIGPLUS			SIGUSR1+1
#define SIGMINUS		SIGUSR1-1
#else
#define SIGPLUS			SIGRTMIN
#define SIGMINUS		SIGRTMIN
#endif
#define LENGTH(X)		(sizeof(X) / sizeof (X[0]))
#define CMDLENGTH		50
#define MIN(a, b)		((a < b) ? a : b)
#define STATUSLENGTH	(LENGTH(blocks) * CMDLENGTH + 1)

typedef struct {
	char* icon;
	char* (*func)(void);
	unsigned int interval;
	unsigned int signal;
} Block;
#ifndef __OpenBSD__
void dummysighandler(int num);
#endif
void sighandler(int num);
void getcmds(int time);
void getsigcmds(unsigned int signal);
void setupsignals(void);
int getstatus(char *str, char *last);
void statusloop(void);
void termhandler(int signum);
void pstdout(void);
#ifndef NO_X
void setroot(void);
static void (*writestatus) (void) = setroot;
static int setupX(void);
static Display *dpy;
static int screen;
static Window root;
#else
static void (*writestatus) () = pstdout;
#endif

#include "config.h"

static char statusbar[LENGTH(blocks)][CMDLENGTH] = {0};
static char statusstr[2][STATUSLENGTH];
static int statusContinue = 1;
static int returnStatus = 0;

void getcmd(const Block *block, char *output)
{
	if (!block->func) {
		output[0] = '\0';
		return;
	}
	char tempstatus[CMDLENGTH] = {0};
	strcpy(tempstatus, block->icon);
	const char *func_output = block->func();
	if (!func_output) {
		output[0] = '\0';
		return;
	}
	strncat(tempstatus, func_output, CMDLENGTH - strlen(block->icon) - delimLen);
	int i = strlen(tempstatus);
	if (i != 0 && delim[0] != '\0') {
		strncpy(tempstatus + i, delim, delimLen);
	} else {
		tempstatus[i++] = '\0';
	}
	strcpy(output, tempstatus);
}

void getcmds(int time)
{
	const Block* current;
	for (unsigned int i = 0; i < LENGTH(blocks); i++) {
		current = blocks + i;
		if ((current->interval != 0 && time % current->interval == 0) || time == -1)
			getcmd(current, statusbar[i]);
	}
}

void getsigcmds(unsigned int signal)
{
	const Block *current;
	for (unsigned int i = 0; i < LENGTH(blocks); i++) {
		current = blocks + i;
		if (current->signal == signal)
			getcmd(current, statusbar[i]);
	}
}

void setupsignals(void)
{
#ifndef __OpenBSD__
	for (int i = SIGRTMIN; i <= SIGRTMAX; i++)
		signal(i, dummysighandler);
#endif
	for (unsigned int i = 0; i < LENGTH(blocks); i++) {
		if (blocks[i].signal > 0)
			signal(SIGMINUS + blocks[i].signal, sighandler);
	}
}

int getstatus(char *str, char *last)
{
	strcpy(last, str);
	str[0] = '\0';
	for (unsigned int i = 0; i < LENGTH(blocks); i++)
		strcat(str, statusbar[i]);
	str[strlen(str) - strlen(delim)] = '\0';
	return strcmp(str, last);
}

#ifndef NO_X
void setroot(void)
{
	if (!getstatus(statusstr[0], statusstr[1]))
		return;
	XStoreName(dpy, root, statusstr[0]);
	XFlush(dpy);
}

int setupX(void)
{
	dpy = XOpenDisplay(NULL);
	if (!dpy) {
		fprintf(stderr, "dwmblocks: Failed to open display\n");
		return 0;
	}
	screen = DefaultScreen(dpy);
	root = RootWindow(dpy, screen);
	return 1;
}
#endif

void pstdout(void)
{
	if (!getstatus(statusstr[0], statusstr[1]))
		return;
	printf("%s\n", statusstr[0]);
	fflush(stdout);
}

void statusloop(void)
{
	setupsignals();
	int i = 0;
	getcmds(-1);
	while (1) {
		getcmds(i++);
		writestatus();
		if (!statusContinue)
			break;
		sleep(1.0);
	}
}

#ifndef __OpenBSD__
void dummysighandler(int signum)
{
	return;
}
#endif

void sighandler(int signum)
{
	getsigcmds(signum - SIGPLUS);
	writestatus();
}

void termhandler(int signum)
{
	statusContinue = 0;
}

int main(int argc, char** argv)
{
	for (int i = 0; i < argc; i++) {
		if (!strcmp("-d", argv[i]))
			strncpy(delim, argv[++i], delimLen);
		else if (!strcmp("-p", argv[i]))
			writestatus = pstdout;
	}
#ifndef NO_X
	if (!setupX())
		return 1;
#endif
	delimLen = MIN(delimLen, strlen(delim));
	delim[delimLen++] = '\0';
	signal(SIGTERM, termhandler);
	signal(SIGINT, termhandler);
	statusloop();
#ifndef NO_X
	XCloseDisplay(dpy);
#endif
	return returnStatus;
}
