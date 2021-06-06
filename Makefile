SHELL := bash

define generate_pngs
	template="$(1)" ; \
	outputRoot="$(2)" ; \
	targetBg="$(3)" ; \
	targetFg="$(4)" ; \
	mkdir -p outputs ; \
	svg2png="docker run --rm \
	                    -v $$PWD:/home/appuser \
			    -v /usr/share/fonts/:/usr/share/fonts \
			    -v /usr/local/share/fonts/:/usr/local/share/fonts \
			    -v $$HOME/.local/share/fonts/:/home/appuser/.local/share/fonts \
			    --user $$UID guzo/svg2png cairosvg" ; \
	cat colours.txt | while read colours ; do \
		bg=$$(echo $$colours | cut -d',' -f1) ; \
		fg=$$(echo $$colours | cut -d',' -f2) ; \
		png="$$outputRoot-$$bg-$$fg.png" ; \
		cat $$template | sed -e "s/$$targetBg/$$bg/" -e "s/$$targetFg/$$fg/" > $$outputRoot.svg ; \
		$$svg2png $$outputRoot.svg -o $$png; \
		rm $$outputRoot.svg ; \
	done
endef

.PHONY: all
all: clean tiles backgrounds

.PHONY: tiles
tiles:
	template="templates/tile.svg" ; \
	templateBg=$$(grep 'rect { fill' $$template | sed 's/.* \([a-z]*\);.*/\1/') ; \
	templateFg=$$(grep 'path { fill' $$template | sed 's/.* \([a-z]*\);.*/\1/') ; \
	$(call generate_pngs,$$template,outputs/tile,$$templateBg,$$templateFg)

.PHONY: backgrounds
backgrounds:
	template="templates/background.svg" ; \
	templateBg=$$(grep 'tile-' $$template | cut -d'"' -f4 | cut -d'-' -f2) ; \
	templateFg=$$(grep 'tile-' $$template | cut -d'"' -f4 | cut -d'.' -f1 | cut -d'-' -f3) ; \
	svg2png="docker run --rm -v $$PWD:/home/appuser --user $$UID guzo/svg2png cairosvg" ; \
	$(call generate_pngs,$$template,outputs/background,$$templateBg,$$templateFg)

.PHONY: clean
clean:
	rm -f outputs/*
