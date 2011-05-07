#makeAll.sh
SHELL=/bin/sh
prefix=/usr/local

OS=$(shell uname || uname -s)
ARCH=$(shell arch || uname -m)

all: lib

ifndef DC
    ifneq ($(strip $(shell which dmd 2>/dev/null)),)
        DC=dmd
    else ifneq ($(strip $(shell which ldc 2>/dev/null)),)
        DC=ldc
    else
        DC=gdc
    endif
endif

ifeq ("$(DC)","dmd")
    DCFLAGS=-O
    LINKERFLAG=-L
    output=-of$@
else ifeq ("$(DC)","ldc")
    DCFLAGS=-O
    LINKERFLAG=-L
    output=-of$@
else
    DCFLAGS=-O2
    LINKERFLAG=-Xlinker
    output=-o $@
endif

ifeq ("$(OS)","Darwin")
    LDFLAGS+=-Wl,-undefined,dynamic_lookup
else ifeq ("$(OS)","Linux")
    LDFLAGS+=$(LINKERFLAG)-ldl
endif

ifeq ("$(ARCH)", "x86_64") 
    DCFLAGS+=-m64
    LDFLAGS+=-m64
endif 

AR=ar
RANLIB=ranlib

#######################################################################

LIBNAME_DMAGICK = libdmagick.a
SOURCES_DMAGICK = $(shell find \
        dmagick \
        -name '*.d' )
OBJECTS_DMAGICK = $(shell echo $(SOURCES_DMAGICK) | sed -e 's/\.d/\.o/g')

#######################################################################

lib: $(LIBNAME_DMAGICK)

$(LIBNAME_DMAGICK): IMPORTS=-Idmagick
$(LIBNAME_DMAGICK): $(OBJECTS_DMAGICK)
	$(AR) rcs $@ $^
	$(RANLIB) $@

#######################################################################

%.o : %.d
	$(DC) $(DCFLAGS) $(IMPORTS) -c $< $(output)

#######################################################################

install: lib
	install -d $(DESTDIR)$(prefix)/include/d
	(echo $(SOURCES_DMAGICK) | xargs tar c) | (cd $(DESTDIR)$(prefix)/include/d; tar xv)
	install -d $(DESTDIR)$(prefix)/lib
	install -m 644 $(LIBNAME_DMAGICK) $(DESTDIR)$(prefix)/lib
	
uninstall:
	rm -rf $(DESTDIR)$(prefix)/include/d/dmagick
	rm -f $(DESTDIR)$(prefix)/lib/$(LIBNAME_DMAGICK)

clean:
	-rm -f $(LIBNAME_DMAGICK) $(OBJECTS_DMAGICK)
