#makeAll.sh
SHELL=/bin/sh
prefix=/usr/local

DMAGICK_VERSION=0.2.0

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
    VERSIONFLAG=-fversion=
    DDOCFLAGS=-fsyntax-only -c -fdoc -fdoc-file=$@
    DDOCINC=-fdoc-inc=
    output=-o $@
else ifeq ("$(DC)","ldc2")
    DCFLAGS=-O
    LINKERFLAG=-L
    UNITTESTFLAG=-unittest
    VERSIONFLAG=-d-version=
    DDOCFLAGS=-o- -Df$@
    output=-of$@
else
    DCFLAGS=-O
    LINKERFLAG=-L
    UNITTESTFLAG=-unittest
    VERSIONFLAG=-version=
    DDOCFLAGS=-o- -Df$@
    output=-of$@
endif

ifeq ("$(ARCH)", "x86_64") 
    DCFLAGS+=-m64
    LDFLAGS+=-m64
endif 

MAGICKCORELIB=$(LINKERFLAG)-l$(shell pkg-config --variable=libname MagickCore)

AR=ar
RANLIB=ranlib

QUANTUMDEPTH = $(filter Q%,$(shell convert --version))
MAGICKVERSION = $(firstword $(subst -, ,$(word 3,$(shell convert --version))))
HDRISUPPORT = $(findstring HDRI,$(shell convert --version | grep HDRI))

ifeq ("$(HDRISUPPORT)","HDRI")
    HDRI=true
else
    HDRI=false
endif

#######################################################################

LIBNAME_DMAGICK = libDMagick.a
SOURCES_DMAGICK = $(sort $(wildcard dmagick/*.d)) \
                  $(sort $(wildcard dmagick/c/*.d)) \
                  dmagick/c/magickVersion.d

OBJECTS_DMAGICK = $(patsubst %.d,%.o,$(SOURCES_DMAGICK))
DOCS_DMAGICK    = $(patsubst dmagick/%.d,docs/%.html,$(SOURCES_DMAGICK))

#######################################################################

lib: $(LIBNAME_DMAGICK)

$(LIBNAME_DMAGICK): $(OBJECTS_DMAGICK)
	$(AR) rcs $@ $^
	$(RANLIB) $@

dmagick/c/magickVersion.d: dmagick/c/magickVersion.d.in
	sed 's/@MagickLibVersion@/$(subst .,,$(MAGICKVERSION))/g' $< | sed 's/@MagickLibVersionText@/$(MAGICKVERSION)/g' | sed 's/@QuantumDepth@/$(subst Q,,$(QUANTUMDEPTH))/g' | sed 's/@HDRI@/$(HDRI)/g' > $@

#######################################################################

%.o : %.d dmagick/c/magickVersion.d
	$(DC) $(DCFLAGS) -c $< $(output)

#######################################################################

/tmp/stubmain.d:
	echo "void main(){}" > $@

unittest: /tmp/stubmain.d $(SOURCES_DMAGICK)
	$(DC) $(DCFLAGS) $(UNITTESTFLAG) $(MAGICKCORELIB) $(LDFLAGS) $^ $(output)
	./$@

#######################################################################

html: docs
docs: $(DOCS_DMAGICK)

#######################################################################

docs/c/%.html : dmagick/c/%.d
	$(DC) $(DCFLAGS) $(DDOCINC)docs/dmagick.ddoc $(DDOCINC)docs/dmagick.c.ddoc $< $(DDOCFLAGS) 

docs/%.html : dmagick/%.d
	$(DC) $(DCFLAGS) $(DDOCINC)docs/dmagick.ddoc $< $(DDOCFLAGS) 

#######################################################################

pkgconfig: DMagick.pc

DMagick.pc:
	echo Name: DMagick > $@
	echo Description: DMagick - A D binding for ImageMagick. >> $@
	echo Version: $(DMAGICK_VERSION) >> $@
	echo Libs: $(LINKERFLAG)-L$(prefix)/lib/ $(LINKERFLAG)-lDMagick $(MAGICKCORELIB) >> $@
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
	rm -rf dmagick/c/magickVersion.d
	rm -rf $(LIBNAME_DMAGICK) $(OBJECTS_DMAGICK)
	rm -rf $(DOCS_DMAGICK) docs/c
	rm -rf unittest.o unittest
	rm -rf DMagick.pc
