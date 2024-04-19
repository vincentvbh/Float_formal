
CC = gcc
CFLAGS +=

HEADER = fpr.h
SRC = fpr.c

all: test

test: test.c $(HEADER) $(SRC)
	$(CC) -o $@ $(CFLAGS) test.c $(SRC)

.PHONY: clean
clean:
	rm -f test





