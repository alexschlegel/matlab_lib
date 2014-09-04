
# Makefile for settrigger
all: settrigger

CC = gcc

CFLAGS = -O -Wall

INCLUDE = /usr/src/linux-headers-2.6.32-33-generic/include

sample0: settrigger.c
	$(CC) -I$(INCLUDE) $(CFLAGS) -o settrigger settrigger.c
