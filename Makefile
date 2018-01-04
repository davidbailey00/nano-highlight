LANGS  = apacheconf asm awk c cmake coffeescript colortest csharp css cython \
         default diff dot email git glsl go html ini inputrc java javascript \
         json keymap kickstart ledger lisp lua makefile man markdown mpdconf \
         nanorc nginx patch peg perl php pkg-config pkgbuild po privoxy \
         properties python R rpmspec ruby sed shell sql systemd tex vala vi \
         xml xresources yaml yum

MIXINS = $(wildcard mixins/*.nanorc)
FILES  = $(addsuffix .nanorc, $(LANGS))
ALL    = $(addprefix build/, $(FILES)) build/ALL.nanorc
DIR    = $(HOME)/.nano/syntax
THEME  = custom-theme.sed
FILTER = sed -f mixins.sed | sed -f $(THEME)

all: $(ALL)

build/ALL.nanorc: $(FILES) $(MIXINS) $(THEME) | build/
	@cat $(FILES) | $(FILTER) > $@
	@echo 'Generated: $@'

build/%.nanorc: %.nanorc $(MIXINS) $(THEME) | build/
	@cat $< | $(FILTER) > $@
	@echo 'Generated: $@'

build/:
	@mkdir -p $@

install: all
	@mkdir -p '$(DESTDIR)$(DIR)'
	@install -p -m 0644 $(ALL) '$(DESTDIR)$(DIR)'
	@echo 'Installed: $(DESTDIR)$(DIR)/*.nanorc'

install-global:
	@$(MAKE) --no-print-directory install DIR=/usr/local/share/nano

clean:
	rm -rf build


ifeq ($(shell test -f ~/.nanotheme && echo 1),1)
  THEME = ~/.nanotheme
endif

# Remove "header" directives if not supported (introduced in nano 2.1.6)
NANOVER = $(shell nano -V | sed -n 's/^.* version \([0-9\.]*\).*/\1/p')
ifeq ($(shell printf "2.1.5\n$(NANOVER)" | sort -nr | head -1),2.1.5)
  FILTER += | sed -e '/^header/d'
endif

#Remove "magic" command if not supported (introduced in 2.3)

#Extract just the minor version.
NANOMINORVER = $(shell nano -V | sed -n 's/^.* version \([0-9\.]*\)\..*/\1/p')

SUPPORTMAGIC = $(shell expr $(NANOMINORVER) \>= 2.3)

ifeq ($(SUPPORTMAGIC),0)
  FILTER += | sed -e '/^magic/d'
endif

ifdef TEXT
  FILTER += | sed -e 's|^color \(bright\)\{0,1\}white|color \1$(TEXT)|'
endif

ifdef BSDREGEX
  FILTER += | sed -e 's|\\<|[[:<:]]|g;s|\\>|[[:>:]]|g'
endif


.PHONY: all install install-global clean force
