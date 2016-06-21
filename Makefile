PREFIX=/usr/local/cyruslibs-fastmail-v1

ICU_RELEASE=release-55-1
ICU_SVN_URL=http://source.icu-project.org/repos/icu/icu/tags/$(ICU_RELEASE)/
ICU_SRCDIR=icu/$(ICU_RELEASE)/source

# top level rules
.PHONY: all update install

all: .icu.build

update: .icu.update

install: .icu.install

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

.icu.update: $(ICU_SRCDIR)
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
