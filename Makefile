PREFIX=/usr/local/cyruslibs-fastmail-v1

ICU_RELEASE=release-55-1
ICU_SVN_URL=http://source.icu-project.org/repos/icu/icu/tags/$(ICU_RELEASE)/
ICU_SRCDIR=icu/$(ICU_RELEASE)/source
ICU_BUILDDIR=icu-build

LIBICAL_SRCDIR=libical
LIBICAL_BUILDDIR=libical-build

OPENDKIM_SRCDIR=opendkim
OPENDKIM_BUILDDIR=opendkim-build

# top level rules
.PHONY: all update build install clean

all: build

update: update-icu update-libical update-opendkim

build: .icu.build .libical.build .opendkim.build

install: .icu.install .libical.install .opendkim.install

clean: clean-icu clean-libical clean-opendkim

#
# we get icu from subversion
#
.PHONY: icu update-icu force-update-icu clean-icu

force-update-icu:
	rm -f .icu.update

update-icu: force-update-icu .icu.update

icu: .icu.build

clean-icu:
	rm -fr $(ICU_BUILDDIR) .icu.build

$(ICU_SRCDIR):
	mkdir -p icu
	(cd icu && svn co $(ICU_SVN_URL))

.icu.update: | $(ICU_SRCDIR)
	(cd icu/$(ICU_RELEASE) && svn update)
	touch $@

.icu.build: .icu.update
	( mkdir -p $(ICU_BUILDDIR) && \
	  cd $(ICU_BUILDDIR) && \
	  ../$(ICU_SRCDIR)/configure --prefix=$(PREFIX) && \
	  make )
	touch $@

.icu.install: .icu.build
	( cd $(ICU_BUILDDIR) && sudo make install )
	touch $@

#
# we get libical from a git submodule
#
.PHONY: libical update-libical force-update-libical clean-libical

force-update-libical:
	rm -f .libical.update

update-libical: force-update-libical .libical.update

libical: .libical.build

clean-libical:
	rm -fr $(LIBICAL_BUILDDIR) .libical.build

.libical.update:
	git submodule update --remote $(LIBICAL_SRCDIR)
	touch $@

.libical.build: .libical.update
	( mkdir -p $(LIBICAL_BUILDDIR) && \
	  cd $(LIBICAL_BUILDDIR) && \
	  cmake -DCMAKE_INSTALL_PREFIX=$(PREFIX) ../$(LIBICAL_SRCDIR) && \
	  make )
	touch $@

.libical.install: .libical.build
	( cd $(LIBICAL_BUILDDIR) && \
	  sudo make install )
	touch $@

#
# we get opendkim from a git submodule
#
.PHONY: opendkim update-opendkim force-update-opendkim clean-opendkim

force-update-opendkim:
	rm -f .opendkim.update

update-opendkim: force-update-opendkim .opendkim.update

opendkim: .opendkim.build

clean-opendkim:
	rm -fr $(OPENDKIM_BUILDDIR) .opendkim.build

.opendkim.update:
	git submodule update --remote $(OPENDKIM_SRCDIR)
	( cd $(OPENDKIM_SRCDIR) && \
	  autoreconf -is )
	touch $@

.opendkim.build: .opendkim.update
	( mkdir -p $(OPENDKIM_BUILDDIR) && \
	  cd $(OPENDKIM_BUILDDIR) && \
	  ../$(OPENDKIM_SRCDIR)/configure --enable-silent-rules --prefix=$(PREFIX) && \
	  make )
	touch $@

.opendkim.install: .opendkim.build
	( cd $(OPENDKIM_BUILDDIR) && \
	  sudo make install )
	touch $@
