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
SOURCES_DMAGICK = $(sort $(wildcard dmagick/*.d)) \
                  $(sort $(wildcard dmagick/c/*.d))

OBJECTS_DMAGICK = $(patsubst %.d,%.o,$(SOURCES_DMAGICK))
DOCS_DMAGICK    = $(patsubst dmagick/%.d,docs/%.html,$(SOURCES_DMAGICK))

#######################################################################

lib: $(LIBNAME_DMAGICK)

$(LIBNAME_DMAGICK): $(OBJECTS_DMAGICK)
	$(AR) rcs $@ $^
	$(RANLIB) $@

#######################################################################

%.o : %.d
	$(DC) $(DCFLAGS) $(IMPORTS) -c $< $(output)

#######################################################################

docs: $(DOCS_DMAGICK)

#######################################################################

docs/%.html : dmagick/%.d
	$(DC) $(DCFLAGS) $(IMPORTS) -o- $< -Df$@

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
	-rm -rf $(LIBNAME_DMAGICK) $(OBJECTS_DMAGICK) docs
