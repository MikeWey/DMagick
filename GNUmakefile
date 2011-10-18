#makeAll.sh
SHELL=/bin/sh
prefix=/usr/local

DMAGICK_VERSION=0.0.1

OS=$(shell uname || uname -s)
ARCH=$(shell arch || uname -m)

all: lib pkgconfig

ifndef DC
    ifneq ($(strip $(shell which dmd 2>/dev/null)),)
        DC=dmd
    else ifneq ($(strip $(shell which ldc2 2>/dev/null)),)
        DC=ldc2
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
MAGICKVERSION = $(subst .,,$(firstword $(shell MagickCore-config --version)))

ifneq ("$(QUANTUMDEPTH)","Q16")
    VERSIONS+= -version=$(subst Q,Quantum,$(QUANTUMDEPTH))
endif

ifneq ("$(MAGICKVERSION)","673")
    VERSIONS+= -version=MagickCore_$(MAGICKVERSION)
endif

ifdef VERSIONS
	DCFLAGS+=$(VERSIONS)
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
	echo "void main(){}" > $@)

unittest: /tmp/stubmain.d $(SOURCES_DMAGICK)
	$(DC) $(DCFLAGS) $(UNITTESTFLAG) $(LINKERFLAG)-lMagickCore $^ $(output)
	./$@

#######################################################################

html: docs
docs: $(DOCS_DMAGICK)

#######################################################################

docs/%.html : dmagick/%.d
	$(DC) $(DCFLAGS) docs/dmagick.ddoc $< $(DDOCFLAGS) 

docs/c/%.html : dmagick/c/%.d
	$(DC) $(DCFLAGS) docs/dmagick.ddoc docs/dmagick.c.ddoc $< $(DDOCFLAGS) 

#######################################################################

pkgconfig: DMagick.pc

DMagick.pc:
	echo Name: DMagick > $@
	echo Description: DMagick - A D binding for ImageMagick. >> $@
	echo Version: $(DMAGICK_VERSION) >> $@
	echo Libs: $(LINKERFLAG)-L$(prefix)/lib/ $(LINKERFLAG)-lDMagick $(LINKERFLAG)-lMagickCore >> $@
	echo Cflags: -I$(prefix)/include/d/ $(VERSIONS) >> $@

#######################################################################

install: lib pkgconfig
	install -d $(DESTDIR)$(prefix)/include/d
	(echo $(SOURCES_DMAGICK) | xargs tar c) | (cd $(DESTDIR)$(prefix)/include/d; tar xv)
	install -d $(DESTDIR)$(prefix)/lib/pkgconfig
	install -m 644 DMagick.pc $(DESTDIR)$(prefix)/lib/pkgconfig
	install -d $(DESTDIR)$(prefix)/lib
	install -m 644 $(LIBNAME_DMAGICK) $(DESTDIR)$(prefix)/lib
	
uninstall:
	rm -rf $(DESTDIR)$(prefix)/include/d/dmagick
	rm -f $(DESTDIR)$(prefix)/lib/$(LIBNAME_DMAGICK)
	rm -f $(DESTDIR)$(prefix)/lib/pkgconfig/DMagick.pc

clean:
	rm -rf $(LIBNAME_DMAGICK) $(OBJECTS_DMAGICK)
	rm -rf $(DOCS_DMAGICK) docs/c
	rm -rf unittest.o unittest
	rm -rf DMagick.pc
