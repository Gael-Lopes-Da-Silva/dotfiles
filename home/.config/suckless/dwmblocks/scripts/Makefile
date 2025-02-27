CC     := cc
CFLAGS := -pedantic -Wall -Wno-deprecated-declarations -Os

SRCS := battery.c brightness.c date.c volume.c rec.c time.c
BINS := battery brightness date volume rec time

all: $(BINS)

%: %.c
	$(CC) $(CFLAGS) -o $@ $<

clean:
	rm -f $(BINS)

install: $(BINS)
	@for bin in $(BINS); do \
		$(CC) $(CFLAGS) -o $$bin $$bin.c & \
	done; \
	wait
