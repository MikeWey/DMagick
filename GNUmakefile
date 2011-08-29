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

ifeq ("$(DC)","gdc")
    DCFLAGS=-O2
    LINKERFLAG=-Xlinker
    UNITTESTFLAG=-funittest
    DDOCFLAGS=-fdoc-file=$@
    output=-o $@
else
    DCFLAGS=-O
    LINKERFLAG=-L
    UNITTESTFLAG=-unittest
    DDOCFLAGS=-o- -Df$@
    output=-of$@
endif

ifeq ("$(OS)","Linux")
    LDFLAGS+=$(LINKERFLAG)-ldl
endif

ifeq ("$(ARCH)", "x86_64") 
    DCFLAGS+=-m64
    LDFLAGS+=-m64
endif 

AR=ar
RANLIB=ranlib

QUANTUMDEPTH = $(lastword $(shell MagickCore-config --version))

ifneq ("$(QUANTUMDEPTH)","Q16")
    DCFLAGS+= -version=$(subst Q,Quantum,$(QUANTUMDEPTH))
endif

#######################################################################

LIBNAME_DMAGICK = libDMagick.a
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
	$(DC) $(DCFLAGS) -c $< $(output)

#######################################################################

/tmp/stubmain.d:
	$(shell echo "void main(){}" > /tmp/stubmain.d)

unittest: /tmp/stubmain.d $(SOURCES_DMAGICK)
	$(DC) $(DCFLAGS) $(UNITTESTFLAG) $(LINKERFLAG)-lMagickCore $^ $(output)
	./$@

#######################################################################

html: docs
docs: $(DOCS_DMAGICK)

#######################################################################

docs/%.html : dmagick/%.d
	$(DC) $(DCFLAGS) $< $(DDOCFLAGS) 

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
	-rm -rf $(LIBNAME_DMAGICK) $(OBJECTS_DMAGICK) unittest.o unittest docs
