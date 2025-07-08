PREFIX  := /usr/local

# FreeBSD (uncomment)
#LDFLAGS += -L/usr/local/lib -I/usr/local/include
# OpenBSD (uncomment)
#LDFLAGS += -L/usr/X11R6/lib -I/usr/X11R6/include

CFLAGS  := -pedantic -Wall -Wno-deprecated-declarations -Os
LDFLAGS := -lX11

CC := cc
