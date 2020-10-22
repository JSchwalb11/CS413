# Makefile
all: Schwalb

Schwalb: Schwalb.o
	gcc -o Schwalb Schwalb.o

Schwalb.o : Schwalb.s
	as -o Schwalb.o Schwalb.s

clean:
	rm -vf Schwalb *.o
