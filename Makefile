#
#   Makefile for the GNUstep Startup/core packages
#
#   Copyright (C) 2005 Free Software Foundation, Inc.
#
#   Author: Adam Fedor <fedor@doc.com>
#
#   This library is free software; you can redistribute it and/or
#   modify it under the terms of the GNU General Public License
#   as published by the Free Software Foundation; either version 2
#   of the License, or (at your option) any later version.
#   
#   You should have received a copy of the GNU General Public
#   License along with this library; see the file COPYING.LIB.
#   If not, write to the Free Software Foundation,
#   59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.

include Version
VERTAG = $(subst .,_,$(GNUSTEP_START_VERSION))

all:
	InstallGNUstep

clean:
	rm -f *~
	rm -f config.status config.log setupvars config.h

distclean: clean
	rm -rf build
	if [ -f /tmp/gnustepbuild ]; then \
	  cd /tmp; rm -rf gnustepbuild; \
	fi

cvs-tag:
	cvs -z3 rtag start-$(VERTAG) gnustep/Startup

cvs-dist:
	cvs -z3 export -r start-$(VERTAG) gnustep/Startup
	mv gnustep/Startup gnustep-startup-$(GNUSTEP_START_VERSION)
	cd gnustep-startup-$(GNUSTEP_START_VERSION); \
	  mkdir sources; \
	  if [ -d ../../../current ]; then \
	    cp ../../../current/* sources; \
	  fi; \
	  cd ..
	tar --gzip -cf gnustep-startup-$(GNUSTEP_START_VERSION).tar.gz gnustep-startup-$(GNUSTEP_START_VERSION)
	rm -rf gnustep-startup-$(GNUSTEP_START_VERSION)
	rmdir gnustep

snapshot:
	mkdir ../gnustep-startup-snap
	cp -rf * ../gnustep-startup-snap
	mv ../gnustep-startup-snap .
	cd gnustep-startup-snap; \
	  rm -f *~; rm -rf CVS scripts/CVS config/CVS autom4te.cache
	cd gnustep-startup-snap; \
	  mkdir sources; \
	  if [ -d ../../../current ]; then \
	    cp ../../../current/* sources; \
	  fi; \
	  cd ..
	tar --gzip -cf gnustep-startup-snap.tar.gz gnustep-startup-snap
