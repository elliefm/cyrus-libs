PREFIX=/usr/local/cyruslibs-fastmail-v1

ICU_RELEASE=release-55-1
ICU_SVN_URL=http://source.icu-project.org/repos/icu/icu/tags/$(ICU_RELEASE)/
ICU_SRCDIR=icu/$(ICU_RELEASE)/source

LIBICAL_SRCDIR=libical
LIBICAL_BUILDDIR=libical-build

OPENDKIM_SRCDIR=opendkim

# top level rules
.PHONY: all update install

all: .icu.build .libical.build .opendkim.build

update: .icu.update .libical.update .opendkim.update

install: .icu.install .libical.install .opendkim.install

#
# we get icu from subversion
#
.PHONY: icu update-icu force-update-icu

force-update-icu:
	rm .icu.update

update-icu: force-update-icu .icu.update

icu: .icu.build

$(ICU_SRCDIR):
	mkdir -p icu
	(cd icu && svn co $(ICU_SVN_URL))

.icu.update: | $(ICU_SRCDIR)
	(cd icu/$(ICU_RELEASE) && svn update)
	touch $@

.icu.build: .icu.update
	( cd $(ICU_SRCDIR) && \
	  ./configure --prefix=$(PREFIX) && \
	  make )
	touch $@

.icu.install: .icu.build
	( cd $(ICU_SRCDIR) && sudo make install )
	touch $@

#
# we get libical from a git submodule
#
.PHONY: libical update-libical force-update-libical

force-update-libical:
	rm .libical.update

update-libical: force-update-libical .libical.update

libical: .libical.build

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
.PHONY: opendkim update-opendkim force-update-opendkim

force-update-opendkim:
	rm .opendkim.update

update-opendkim: force-update-opendkim .opendkim.update

opendkim: .opendkim.build

.opendkim.update:
	git submodule update --remote $(OPENDKIM_SRCDIR)
	touch $@

.opendkim.build: .opendkim.update
	( cd $(OPENDKIM_SRCDIR) && \
	  autoreconf -is && \
	  ./configure --prefix=$(PREFIX) && \
	  make )
	touch $@

.opendkim.install: .opendkim.build
	( cd $(OPENDKIM_SRCDIR) && \
	  sudo make install )
	touch $@
