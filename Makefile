#
# GNUstep automatic Makefile
#

-include scripts/setupvars

all:
	InstallGNUstep

clean:
	rm -f *~
	rm -f config.status config.log setupvars config.h

distclean: clean

realclean: clean
	cd /tmp; rm -rf gnustep
