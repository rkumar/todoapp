DISTFILES := README.markdown get_serial_number colors.sh todoapp.sh
VERSION := `cat VERSION_FILE`
 
all: install

DISTNAME=todoapp-$(VERSION)
dist: $(DISTFILES)
	echo "ver: $(VERSION)"
	mkdir -p $(DISTNAME)
	cp -f $(DISTFILES) $(DISTNAME)/
	tar cf $(DISTNAME).tar $(DISTNAME)/
	gzip -f -9 $(DISTNAME).tar
	zip -9r $(DISTNAME).zip $(DISTNAME)/
	rm -r $(DISTNAME)

.PHONY: distclean
distclean:
	rm -f $(DISTNAME).tar.gz $(DISTNAME).zip

INSTALL_DIR=~/bin

install:

	## updating todoapp
	# what about copying colors.sh and get_serial_number. Why not read it in ?
	cp -p todoapp.sh $(INSTALL_DIR)/todoapp.sh
	chmod +x $(INSTALL_DIR)/todoapp.sh
	
#
# Testing
#
TESTS = $(wildcard tests/t[0-9][0-9][0-9][0-9]-*.sh)
#TEST_OPTIONS=--verbose

test-pre-clean:
	rm -rf tests/test-results "tests/trash directory"*

aggregate-results: $(TESTS)

$(TESTS): test-pre-clean
	-cd tests && sh $(notdir $@) $(TEST_OPTIONS)

test: aggregate-results
	tests/aggregate-results.sh tests/test-results/t*-*
	rm -rf tests/test-results
    
# Force tests to get run every time
.PHONY: test test-pre-clean aggregate-results $(TESTS)
