# needed environment variables
# (shold be set by the reconos toolchain)
# CROSS_COMPILE
CC = $(CROSS_COMPILE)gcc

CFLAGS += -O2 -g -Wall -static -L $(RECONOS)/linux/lib -I $(RECONOS)/linux/lib/include

all: performance_test.x

APP_OBJS=timing.o

performance_test.x: $(APP_OBJS)
	$(CC) $(APP_OBJS) $(CFLAGS) performance_test.c -o $@ -static -lreconos -lpthread -lm -lrt

clean:
	rm -f *.o *.x

%.o: %.c
	$(CC) -c $(CFLAGS) -o $@ $<
