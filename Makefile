.PHONY: all build test install clean deb
PACKAGE=automirror

all: build

build:
	@echo No build required

test:
	./runtests.sh

install:
	mkdir -p $(DESTDIR)/usr/bin $(DESTDIR)/usr/share/applications $(DESTDIR)/usr/share/icons/hicolor/scalable/apps $(DESTDIR)/usr/share/man/man1
	install -m 0755 automirror.sh -D $(DESTDIR)/usr/bin/automirror
	install -m 0644 automirror.desktop $(DESTDIR)/usr/share/applications
	install -m 0644 automirror.svg $(DESTDIR)/usr/share/icons/hicolor/scalable/apps
	ronn --pipe <README.md | gzip -9 > $(DESTDIR)/usr/share/man/man1/automirror.1.gz

clean:
	rm -Rf debian/$(PACKAGE)* debian/files out/*

deb: clean
	debuild -i -us -uc -b
	mv ../$(PACKAGE)*.{deb,build,changes} out/
	dpkg -I out/*.deb
	dpkg -c out/*.deb

repo:
	../putinrepo out/*.deb

# vim: set ts=4 sw=4 tw=0 noet : 
