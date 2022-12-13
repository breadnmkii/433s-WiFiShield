CC = gcc
DEPENDENCIES = dep/nmap.c dep/airck.c dep/util.c
CFLAGS = -Wall

all:
	$(CC) $(CFLAGS) $(DEPENDENCIES) shield.c -o WIFIshield
	
clean:
	rm -rf ./WIFIshield
