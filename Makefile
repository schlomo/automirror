.PHONY: all build test install clean commit-release release deb repo
PACKAGE=automirror
SHELL=bash
VERSION := $(shell git rev-list HEAD --count --no-merges)
GIT_STATUS := $(shell git status --porcelain)


all: build

build:
	@echo No build required

commit-release:
ifneq ($(GIT_STATUS),)
	$(error Please commit all changes before releasing. $(shell git status 1>&2))
endif
	gbp dch --full --release --new-version=$(VERSION) --distribution stable --auto --git-author --commit
	git push

release: commit-release deb
	@latest_tag=$$(git describe --tags `git rev-list --tags --max-count=1`); \
	comparison="$$latest_tag..HEAD"; \
	if [ -z "$$latest_tag" ]; then comparison=""; fi; \
	changelog=$$(git log $$comparison --oneline --no-merges --reverse); \
	github-release schlomo/$(PACKAGE) v$(VERSION) "$$(git rev-parse --abbrev-ref HEAD)" "**Changelog**<br/>$$changelog" 'out/*.deb'; \
	git pull
	dput ppa:sschapiro/ubuntu/ppa/xenial out/$(PACKAGE)_*_source.changes

test:
	./runtests.sh

install:
	mkdir -p $(DESTDIR)/usr/bin $(DESTDIR)/usr/share/applications $(DESTDIR)/usr/share/icons/hicolor/scalable/apps $(DESTDIR)/usr/share/man/man1
	install -m 0755 automirror.sh -D $(DESTDIR)/usr/bin/automirror
	install -m 0644 automirror*.desktop $(DESTDIR)/usr/share/applications
	install -m 0644 automirror*.svg $(DESTDIR)/usr/share/icons/hicolor/scalable/apps
	ronn --pipe <README.md | gzip -9 > $(DESTDIR)/usr/share/man/man1/automirror.1.gz

clean:
	rm -Rf debian/$(PACKAGE)* debian/files out/*

deb: clean
ifneq ($(MAKECMDGOALS), release)
	$(eval DEBUILD_ARGS := -us -uc)
endif
	debuild $(DEBUILD_ARGS) -i -b --lintian-opts --profile debian
	debuild $(DEBUILD_ARGS) -i -S --lintian-opts --profile debian
	mkdir -p out
	mv ../$(PACKAGE)*.{xz,dsc,deb,build,changes} out/
	dpkg -I out/*.deb
	dpkg -c out/*.deb

repo:
	../putinrepo.sh out/*.deb

# vim: set ts=4 sw=4 tw=0 noet :
