# Generated automatically from Makefile.in by configure.
#######################################################################
# $Header$
# DOH 
#######################################################################

#.KEEP_STATE:

# Set your C++ compiler here.   g++ works on most machines,
# but you might have to change it depending on your installation.
#
CC      = cc
prefix     = /usr/local

# Comment out the following line if you're on an SGI or don't have ranlib!
RANLIB  = ranlib
AR      = ar

########################################################################
# Normally, you shouldn't have to change anything below this point     #
########################################################################

LIBOBJS = void.o fio.o memory.o base.o file.o list.o hash.o string.o 

LIBSRCS = void.c fio.c memory.c base.c file.c list.c hash.c string.c

LIBHEADERS = ../Include/doh.h
LIB      = ../libdoh.a
INCLUDE  = -I../Include
CFLAGS   = 
SHELL  = /bin/sh

#
# Rules for creation of a .o file from .cxx
.SUFFIXES: .c
.c.o: 
	$(CC) $(INCLUDE) $(CFLAGS) -c -o $*.o $<

all: $(LIB)

$(LIB): $(LIBOBJS) 
	@echo "Building library"
	$(AR) cr $(LIB) $(LIBOBJS)
	$(RANLIB) $(LIB)

clean::
	rm -f *.o ../libdoh.a
nuke::
	rm -f Makefile *~ #* core a.out

