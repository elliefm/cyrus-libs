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

build: .icu.built .libical.built .opendkim.built

install: .icu.installed .libical.installed .opendkim.installed

clean: clean-icu clean-libical clean-opendkim

#
# we get icu from subversion
#
.PHONY: icu update-icu force-update-icu clean-icu

force-update-icu:
	rm -f .icu.updated

update-icu: force-update-icu .icu.updated

icu: .icu.built

clean-icu:
	rm -fr $(ICU_BUILDDIR) .icu.built

$(ICU_SRCDIR):
	mkdir -p icu
	(cd icu && svn co $(ICU_SVN_URL))

.icu.updated: | $(ICU_SRCDIR)
	(cd icu/$(ICU_RELEASE) && svn update)
	touch $@

.icu.built: .icu.updated
	( mkdir -p $(ICU_BUILDDIR) && \
	  cd $(ICU_BUILDDIR) && \
	  ../$(ICU_SRCDIR)/configure --prefix=$(PREFIX) && \
	  make )
	touch $@

.icu.installed: .icu.built
	( cd $(ICU_BUILDDIR) && sudo make install )
	touch $@

#
# we get libical from a git submodule
#
.PHONY: libical update-libical force-update-libical clean-libical

force-update-libical:
	rm -f .libical.updated

update-libical: force-update-libical .libical.updated

libical: .libical.built

clean-libical:
	( cd $(LIBICAL_SRCDIR) && \
	  git clean -xfd )
	rm -fr $(LIBICAL_BUILDDIR) .libical.built

.libical.updated:
	git submodule update --remote $(LIBICAL_SRCDIR)
	touch $@

.libical.built: .libical.updated
	( mkdir -p $(LIBICAL_BUILDDIR) && \
	  cd $(LIBICAL_BUILDDIR) && \
	  cmake -DCMAKE_INSTALL_PREFIX=$(PREFIX) ../$(LIBICAL_SRCDIR) && \
	  make )
	touch $@

.libical.installed: .libical.built
	( cd $(LIBICAL_BUILDDIR) && \
	  sudo make install )
	touch $@

#
# we get opendkim from a git submodule
#
.PHONY: opendkim update-opendkim force-update-opendkim clean-opendkim

force-update-opendkim:
	rm -f .opendkim.updated

update-opendkim: force-update-opendkim .opendkim.updated

opendkim: .opendkim.built

clean-opendkim:
	( cd $(OPENDKIM_SRCDIR) && \
	  git clean -xfd )
	rm -fr $(OPENDKIM_BUILDDIR) .opendkim.built

.opendkim.updated:
	git submodule update --remote $(OPENDKIM_SRCDIR)
	( cd $(OPENDKIM_SRCDIR) && \
	  autoreconf -is )
	touch $@

.opendkim.built: .opendkim.updated
	( mkdir -p $(OPENDKIM_BUILDDIR) && \
	  cd $(OPENDKIM_BUILDDIR) && \
	  ../$(OPENDKIM_SRCDIR)/configure --enable-silent-rules --prefix=$(PREFIX) && \
	  make )
	touch $@

.opendkim.installed: .opendkim.built
	( cd $(OPENDKIM_BUILDDIR) && \
	  sudo make install )
	touch $@
