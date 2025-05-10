PREFIX  := /usr/local
CC      := cc
CFLAGS  := -pedantic -Wall -Wno-deprecated-declarations -Os
LDFLAGS := -lX11

# FreeBSD (uncomment)
#LDFLAGS += -L/usr/local/lib -I/usr/local/include
# OpenBSD (uncomment)
#LDFLAGS += -L/usr/X11R6/lib -I/usr/X11R6/include

# Component source files
COMPONENTS_DIR := components
COMPONENTS_SRC := $(wildcard $(COMPONENTS_DIR)/*.c)
COMPONENTS_OBJ := $(COMPONENTS_SRC:.c=.o)

all: options dwmblocks

options:
	@echo dwmblocks build options:
	@echo "CFLAGS  = ${CFLAGS}"
	@echo "LDFLAGS = ${LDFLAGS}"
	@echo "CC      = ${CC}"

# Compile component source files
$(COMPONENTS_DIR)/%.o: $(COMPONENTS_DIR)/%.c
	${CC} ${CFLAGS} -c $< -o $@

dwmblocks: dwmblocks.c $(COMPONENTS_OBJ) config.h
	${CC} -o dwmblocks dwmblocks.c $(COMPONENTS_OBJ) ${CFLAGS} ${LDFLAGS}

config.h:
	cp config.def.h $@

clean:
	rm -f *.o *.gch dwmblocks $(COMPONENTS_DIR)/*.o

install: dwmblocks
	mkdir -p ${DESTDIR}${PREFIX}/bin
	cp -f dwmblocks ${DESTDIR}${PREFIX}/bin
	chmod 755 ${DESTDIR}${PREFIX}/bin/dwmblocks

uninstall:
	rm -f ${DESTDIR}${PREFIX}/bin/dwmblocks

.PHONY: all options clean install uninstall
