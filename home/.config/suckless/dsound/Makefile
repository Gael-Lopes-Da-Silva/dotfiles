include config.mk

all: dsound

dsound: dsound.c config.h
	${CC} -o dsound dsound.c ${CFLAGS} ${LDFLAGS}

config.h:
	cp config.def.h $@

clean:
	rm -f *.o *.gch dsound

install: dsound
	mkdir -p ${DESTDIR}${PREFIX}/bin
	cp -f dsound dsound_play dsound_stop dsound_setup ${DESTDIR}${PREFIX}/bin
	chmod 755 ${DESTDIR}${PREFIX}/bin/dsound
	chmod 755 ${DESTDIR}${PREFIX}/bin/dsound_play
	chmod 755 ${DESTDIR}${PREFIX}/bin/dsound_stop
	chmod 755 ${DESTDIR}${PREFIX}/bin/dsound_setup

uninstall:
	rm -f ${DESTDIR}${PREFIX}/bin/dsound

.PHONY: all clean install uninstall
