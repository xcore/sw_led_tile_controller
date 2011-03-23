
ifdef OS
winflag :=  -lws2_32
ext = .exe
else
ext = 
endif

all:
	gcc src/ledconfig.c ${winflag} -o bin/ledconfig${ext}