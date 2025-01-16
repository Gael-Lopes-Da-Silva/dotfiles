CC := gcc
CFLAGS := -Wall -Wextra -O2

SRCS := battery.c brightness.c date.c volume.c rec.c time.c
BINS := battery brightness date volume rec time

all: $(BINS)

%: %.c
	$(CC) $(CFLAGS) -o $@ $<

clean:
	rm -f $(BINS)

install:
	$(CC) $(CFLAGS) -o battery battery.c & \
	$(CC) $(CFLAGS) -o brightness brightness.c & \
	$(CC) $(CFLAGS) -o date date.c & \
	$(CC) $(CFLAGS) -o volume volume.c & \
	$(CC) $(CFLAGS) -o rec rec.c & \
	$(CC) $(CFLAGS) -o time time.c & \
	wait
