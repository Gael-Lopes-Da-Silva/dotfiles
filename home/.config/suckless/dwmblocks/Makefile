PREFIX  := /usr/local
CC      := cc
CFLAGS  := -pedantic -Wall -Wno-deprecated-declarations -Os
LDFLAGS := -lX11

# FreeBSD (uncomment)
#LDFLAGS += -L/usr/local/lib -I/usr/local/include
# # OpenBSD (uncomment)
#LDFLAGS += -L/usr/X11R6/lib -I/usr/X11R6/include

all: dwmblocks

dwmblocks: dwmblocks.c config.def.h config.h
	${CC} -o dwmblocks dwmblocks.c ${CFLAGS} ${LDFLAGS}

config.h:
	cp config.def.h $@

clean:
	rm -f *.o *.gch dwmblocks

install: dwmblocks
	mkdir -p ${DESTDIR}${PREFIX}/bin
	cp -f dwmblocks ${DESTDIR}${PREFIX}/bin
	chmod 755 ${DESTDIR}${PREFIX}/bin/dwmblocks
	cd ./scripts && make install

uninstall:
	rm -f ${DESTDIR}${PREFIX}/bin/dwmblocks

.PHONY: all options clean install uninstall
