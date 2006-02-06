#
#   configure.ac
#
#   Copyright (C) 2003,2004,2005 Free Software Foundation, Inc.
#
#   Written: Adam Fedor <fedor@gnu.org>
#   Date: May 2003
#
#   This file is part of GNUstep 
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
AC_INIT([GNUstep Setup], 0.12.0, [bug-gnustep@gnu.org])
AC_PREREQ(2.57)

# From gnustep-base
builtin(include, config/objc-con-autoload.m4)dnl
builtin(include, config/objc-sys-dynamic.m4)dnl
builtin(include, config/pathxml.m4)dnl

SETUP_ERRORS=

AC_CANONICAL_TARGET([])
AC_CONFIG_SRCDIR([InstallGNUstep])



#---------------------------------------------------------------------
# Location of the GNUstep.conf config file (--with-config-file)
#---------------------------------------------------------------------
AC_MSG_CHECKING([for GNUstep configuration file to use])
AC_ARG_WITH(config-file,
  [--with-config-file=PATH  path to GNUstep configuration file],
  GNUSTEP_CONFIG_FILE="$withval", 
  [if test "$GNUSTEP_CONFIG_FILE" = ""; then
    case "$target_os" in
      freebsd* | openbsd* ) GNUSTEP_CONFIG_FILE=/usr/etc/GNUstep.conf ;;
      netbsd* )             GNUSTEP_CONFIG_FILE=/usr/pkg/etc/GNUstep.conf ;;
      *)	            GNUSTEP_CONFIG_FILE=/etc/GNUstep/GNUstep.conf;;
    esac
  fi])
AC_MSG_RESULT($GNUSTEP_CONFIG_FILE)
AC_SUBST(GNUSTEP_CONFIG_FILE)

#---------------------------------------------------------------------
# Now read/import the existing configuration file, if any
#---------------------------------------------------------------------

# Reading/importing the existing configuration file is good as a
# default because it means that you don't have to type in your
# GNUSTEP_SYSTEM_ROOT, GNUSTEP_LOCAL_ROOT, etc. settings every time
# you configure gnustep-make. (please note we only read the
# system-wide one, not the user one.  Reason being that the settings
# we read will be used to generate the new system-wide one, while the
# user one will be left untouched).

# It can be annoying in certain cases though; this option lets you
# turn it off
AC_MSG_CHECKING([if we should import an existing configuration file])
AC_ARG_ENABLE(importing-config-file, 
[--disable-importing-config-file		Disable importing the existing GNUstep configuration file], 
  ac_cv_importing_config_file=$enableval,
  ac_cv_importing_config_file="yes")

# If importing the file is disabled, don't import it.
if test "$ac_cv_importing_config_file" = "no"; then
  AC_MSG_RESULT([no: disabled from the command-line])
else

 # Check that the file exists
 if test "x$prefix" = "xNONE"; then
   if test ! -f "$GNUSTEP_CONFIG_FILE"; then
    AC_MSG_RESULT([no: file "$GNUSTEP_CONFIG_FILE" does not exist])
   else
    AC_MSG_RESULT([yes: trying to import "$GNUSTEP_CONFIG_FILE"])
    AC_MSG_NOTICE([If this fails, please run configure again with the --disable-importing-config-file option])
    . "$GNUSTEP_CONFIG_FILE"
   fi
 else
   AC_MSG_RESULT([no: prefix specified])
 fi
fi

#--------------------------------------------------------------------
# Important - from now on, any variable that is set in the
# configuration file (eg, GNUSTEP_SYSTEM_ROOT) could already have a
# value that we have imported from the previous file.  ./configure
# command line options should override those values, but otherwise we
# should keep them!
#
# Those could also be env variables, which is really a backwards
# compatibility hack that won't necessarily be kept in the future!
#--------------------------------------------------------------------


#--------------------------------------------------------------------
# Process --prefix
#--------------------------------------------------------------------

#
# In practice,
#
# ./configure --prefix=/usr/GNUstep
#
# is equivalent to:
#
# ./configure --with-system-root=/usr/GNUstep/System
#             --with-local-root=/usr/GNUstep/Local
#
# plus it has the side-effect that a config.site will be loaded by
# ./configure from $prefix/share/config.site, if it exists.  Our
# config.site is in $prefix/System/share/config.site though, so it
# won't be found.  It doesn't really matter though, as the config.site
# is irrelevant for us in this context.
#

# Please note that AC_PREFIX_DEFAULT will not appear in this position
# in the generated configure file; it will appear at the very
# beginning.  So we can't check for GNUSTEP_SYSTEM_ROOT or anything
# similar in the implementation of AC_PREFIX_DEFAULT because we will
# not have read GNUstep.conf yet ...  

# PS: This is the default GNUSTEP_ROOT that is used when installing
# GNUstep with no other indication.  Test for the C: directory, which
# means we're on Windows
AC_PREFIX_DEFAULT(`if test -d C: ; then
    echo C:/GNUstep;
  else
    echo /usr/GNUstep ;
  fi`)

#
# GNUSTEP_ROOT is only used to set default values for
# GNUSTEP_SYSTEM_ROOT and GNUSTEP_LOCAL_ROOT if they are not set in
# config file or as a command-line argument.
#
if test "x$prefix" = "xNONE"; then
  GNUSTEP_ROOT="$ac_default_prefix" ;
  if [ -z "$GNUSTEP_SYSTEM_ROOT" ]; then
    # Prefix not set and not read from config file and no env variable
    # So set it to the default
    GNUSTEP_SYSTEM_ROOT="$GNUSTEP_ROOT/System";
  fi
else
  GNUSTEP_ROOT="$prefix";

  # Set the values for all those variables ovverriding anything read
  # from the configuration file or inherited from the environment.
  # The --prefix=xxx option should overwrite those.  Please notice
  # that the --with-system-root=xxx (and similar) options are
  # processed later as overwrite --prefix=xxx in their specific area.
  GNUSTEP_SYSTEM_ROOT="$GNUSTEP_ROOT/System";
  GNUSTEP_LOCAL_ROOT="$GNUSTEP_ROOT/Local";
  GNUSTEP_NETWORK_ROOT="$GNUSTEP_LOCAL_ROOT";
  GNUSTEP_MAKEFILES="$GNUSTEP_SYSTEM_ROOT/Library/Makefiles"
fi

#--------------------------------------------------------------------
# Host, compiler checks
#--------------------------------------------------------------------
AC_PROG_CC
AC_PROG_CPP

AC_MSG_CHECKING(for library combo)
AC_ARG_WITH(library-combo,[
--with-library-combo		Define the default library combination
],
ac_cv_library_combo=$withval,
ac_cv_library_combo=$ac_cv_library_combo
)

if test "$ac_cv_library_combo" = ""; then
  case "$host_os" in
    darwin*)   ac_cv_library_combo=apple-apple-apple ;;
    nextstep4) ac_cv_library_combo=nx-nx-nx          ;;
    openstep4) ac_cv_library_combo=nx-nx-nx          ;;
    *)         ac_cv_library_combo=gnu-gnu-gnu       ;;
  esac
fi
case "$ac_cv_library_combo" in
  apple) ac_cv_library_combo=apple-apple-apple ;;
  gnu)   ac_cv_library_combo=gnu-gnu-gnu ;;
  nx)    ac_cv_library_combo=nx-nx-nx ;;
esac

AC_SUBST(ac_cv_library_combo)
AC_MSG_RESULT($ac_cv_library_combo)

#--------------------------------------------------------------------
# specific target_os options
#--------------------------------------------------------------------
case "$target_os" in
  freebsd* | openbsd* )	
	        CPPFLAGS="$CPPFLAGS -I/usr/local/include"
		LDFLAGS="$LDFLAGS -L/usr/local/lib";;
  netbsd*)	CPPFLAGS="$CPPFLAGS -I/usr/pkg/include"
		LDFLAGS="$LDFLAGS -Wl,-R/usr/pkg/lib -L/usr/pkg/lib";;
esac

#--------------------------------------------------------------------
# Determine the host, build, and target systems
#--------------------------------------------------------------------
case $target_os in
  *cygwin*  ) CYGWIN=yes;;
  *mingw32* ) MINGW32=yes;;
          * ) MINGW32=no
              CYGWIN=no;;
esac
AC_MSG_NOTICE([Configuring on $target_os])
AC_EXEEXT
AC_OBJEXT

# Compiler version
AC_MSG_CHECKING(compiler version)
GCC_VERSION=0
if test ! ${GCC} = "yes" ; then
  AC_MSG_RESULT(no: it's not gcc)
  SETUP_ERRORS="$SETUP_ERRORS E090"
else
  # Running gcc -dumpversion we get something like 2.95.4 or
  #  egcs-2.91.66 or 3.0.2 or 3.1 20011211
  # We want to discard anything but the major number.
  # Explanation of the regexp -
  # \(^[^0-9]*\) matches beginning of line and following non numeric chars
  # \([0-9][0-9]*\) matches 1 or more numeric chars (this is the 2^nd
  #  subpattern)
  # \([^0-9].*\) matches a non numeric char followed by anything
  # /\2/ replace the whole lot with the 2^nd subpattern
  gs_cv_gcc_major_version=`${CC} -dumpversion | sed "s/\./ /g" | awk '{print $1}'`;
  gs_cv_gcc_minor_version=`${CC} -dumpversion | sed "s/\./ /g" | awk '{print $2}'`;

  if test "${gs_cv_gcc_major_version}" -ge "3" ; then
    AC_MSG_RESULT(gcc major version is ${gs_cv_gcc_major_version})
  else
    AC_MSG_RESULT(gcc major version is ${gs_cv_gcc_major_version})
  fi
  GCC_VERSION=${gs_cv_gcc_major_version}
fi
AC_SUBST(GCC_VERSION)

if test "$GCC_VERSION" = 2 -a "$gs_cv_gcc_minor_version=" = 96; then
  SETUP_ERRORS="$SETUP_ERRORS W092"
fi

#--------------------------------------------------------------------
# Check if we are using Apple cc
#--------------------------------------------------------------------
cc_cppprecomp=0
cc_byndle=0
AC_MSG_CHECKING([for apple compiler])
${CC} -v 2>&1 | grep Apple > /dev/null
cc_result=$?
# 0 means we have the flag
cc_apple=no
if test  $cc_result = 0; then
  case $host_os in
     darwin*)
       SETUP_ERRORS="$SETUP_ERRORS E093"
       cc_apple=yes;;
  esac
fi
AC_MSG_RESULT($cc_apple)

#--------------------------------------------------------------------
# Find the binary and compile tools
#--------------------------------------------------------------------
AC_CHECK_PROG(AR, ar, ar)
AC_CHECK_PROG(LD, ld, ld)
AC_CHECK_PROG(DLLTOOL, dlltool, dlltool)
AC_CHECK_PROGS(AWK, gawk awk, awk)

AC_PROG_RANLIB

AC_PROG_INSTALL
AC_PROG_LN_S([])
AC_PATH_PROG(WHOAMI, whoami, echo, $PATH:/usr/ucb)

GNU_MAKE=make
case $host_os in
     *bsd* | *BSD*)
       GNU_MAKE=gmake;;
esac
AC_CHECK_PROG(GNUMAKE, $GNU_MAKE)
AC_MSG_CHECKING(make version > 3.75)
make_version=[`$GNU_MAKE --version | grep "[0-9]\.[0-9][0-9]" | sed "s/\(^[^0-9]*\)\([0-9]\.[0-9][0-9]*\)\([^0-9].*\)/\2/"`]
if test -n "$make_version" -a "$make_version" \> 3.74; then
  AC_MSG_RESULT(yes $make_version)
else
  AC_MSG_RESULT(no $make_version)
  SETUP_ERRORS="$SETUP_ERRORS W102"
fi

AC_MSG_CHECKING(broken make)
rm -f maketest
echo "all:" > maketest
echo "	    @echo \$(LD_LIBRARY_PATH)" >> maketest
make_broken=[`make -f maketest --warn-undefined-variables 2>&1 | grep -c warn`]
rm -f maketest
if test "$make_broken" = 1; then
  AC_MSG_RESULT(broken)
  case $host_os in
    darwin*) ;;
    *)  SETUP_ERRORS="$SETUP_ERRORS W109" ;;
  esac
else
  AC_MSG_RESULT(ok)
fi

if test x"$ac_cv_prog_LD" != x; then
  AC_MSG_CHECKING(binutils version > 2.9)
  ld_version=[`ld --version 2>/dev/null | grep "[0-9]\.[0-9]" | sed "s/\(^[^0-9]*\)\([0-9]\.[0-9][0-9]*\)\([^0-9].*\)/\2/" 2>/dev/null`]
  ld_minor_version=`echo $ld_version | tr '.' ' ' | awk '{print $2}'`
  if test -n "$ld_version" -a "$ld_minor_version" \> 1; then
    AC_MSG_RESULT(yes $ld_version)
  else
    AC_MSG_RESULT(no $ld_version)
    case $host_os in
      *darwin*)
        ;;
      *solaris*)
        SETUP_ERRORS="$SETUP_ERRORS W103";;
      *)
        if test x"$ld_version" = x; then
          SETUP_ERRORS="$SETUP_ERRORS I105"
        else
          SETUP_ERRORS="$SETUP_ERRORS W104"
        fi;;
    esac
  fi
else
  SETUP_ERRORS="$SETUP_ERRORS E101"
fi

AC_MSG_CHECKING(iconv version > 2.1)
iconv_version=[`iconv -V 2>/dev/null | grep "[0-9]\.[0-9]" | sed "s/\(^[^0-9]*\)\([0-9]\.[0-9][0-9]*\)\([^0-9].*\)/\2/"`]
if test -n "$iconv_version" -a "$iconv_version" \> 2.1; then
  AC_MSG_RESULT(yes $iconv_version)
else
  AC_MSG_RESULT(no $iconv_version)
fi

#--------------------------------------------------------------------
# Simple way to add a bunch of paths to the flags
#--------------------------------------------------------------------
AC_ARG_WITH(include-flags,
    [  --with-include-flags=FLAGS specify all include flags at once],
    include_flags="$withval", include_flags="no")
if test ${include_flags} != "no"; then
    CPPFLAGS="$CPPFLAGS ${include_flags}"
fi

AC_ARG_WITH(library-flags,
    [  --with-library-flags=FLAGS specify all library flags at once],
    library_flags="$withval", library_flags="no")
if test ${library_flags} != "no"; then
    LDFLAGS="$LDFLAGS ${library_flags}"
fi

#--------------------------------------------------------------------
# Check for iconv support (for Unicode conversion).
#--------------------------------------------------------------------
# Do this before checking for xml2,  as xml2 may require iconv.
#
# We need to find an iconv library that matches the installed iconv.h header
# (if any). It is important to check header/library compatibility. It's
# fairly common to have iconv support both in libc and from libiconv. In that
# case, a naive check that iconv() is in libc will succeed, but if we use
# libiconv's iconv.h, it will redefine iconv() to functions that exist
# only in libiconv, and we'll get link errors.
#
# First, check if there's a working iconv in libc (ie. if the test program
# compiles and links without any extra flags).
AC_MSG_CHECKING(iconv support)
AC_LINK_IFELSE([[#include <iconv.h>
int main(int argc,char **argv) { iconv_open("foo","bar"); }]]
,
  # libc has a working iconv.
  AC_DEFINE(HAVE_ICONV,1, [Define if you have this function])
  AC_MSG_RESULT([[yes, in libc]])
  found_iconv=yes
,
  found_iconv=no
)

if test $found_iconv = no ; then
  old_LIBS="$LIBS"
  LIBS="-liconv $LIBS"
  AC_LINK_IFELSE([[#include <iconv.h>
  int main(int argc,char **argv) { iconv_open("foo","bar"); }]]
  ,
    # -liconv works.
    AC_DEFINE(HAVE_ICONV,1, [Define if you have this function])
    AC_MSG_RESULT([[yes, -liconv]])
    found_iconv=yes
  ,
    found_iconv=no
    LIBS="$old_LIBS"
  )
fi

if test $found_iconv = no ; then
  # -liconv didn't work. Try giconv.h and -lgiconv.
  # BSDs install this lib as libgiconv.
  old_LIBS="$LIBS"
  LIBS="-lgiconv $LIBS"
  AC_LINK_IFELSE([[#include <giconv.h>
  int main(int argc,char **argv) { iconv_open("foo","bar"); }]]
  ,
    AC_DEFINE(HAVE_ICONV,1, [Define if you have this function])
    AC_DEFINE(HAVE_GICONV,1, [Define if you have this function])
    AC_MSG_RESULT([[yes, -lgiconv]])
    found_iconv=yes
  ,
    AC_MSG_RESULT([[no]])
    LIBS="$old_LIBS"
  )
fi

if test $found_iconv = no; then
  SETUP_ERRORS="$SETUP_ERRORS I106"
fi
#--------------------------------------------------------------------
# Check recent libxml for Properytlists, GSXML, GSDoc etc.
#--------------------------------------------------------------------

AC_ARG_ENABLE(xml,
  [  --disable-xml			Compile even if XML-dependencies are not met],,
  enable_xml=yes)

case $host_os in
  *mingw*)
    enable_xml=no;;
  *)
   ;;
esac

if test $enable_xml = yes; then
  # Save CFLAGS and LIBS as AM_PATH_XML clobbers these variables regardless
  # of the success of the macro.
  saved_LIBS="$LIBS"
  saved_CFLAGS="$CFLAGS"

  AM_PATH_XML(2.3.0, enable_libxml=yes, enable_libxml=no)
  if test $enable_libxml = yes; then
    CPPFLAGS="$CPPFLAGS $XML_CFLAGS"
    INCLUDE_FLAGS="$INCLUDE_FLAGS $XML_CFLAGS"
    LIBS="$XML_LIBS $LIBS"
    HAVE_LIBXML=1
    AC_DEFINE(HAVE_LIBXML,1,[Define if libxml available])
    AC_CHECK_HEADERS(libxml/SAX2.h)
    #--------------------------------------------------------------------
    # Check for (optional) libxslt
    #--------------------------------------------------------------------
    enable_xslt=yes

    if test $enable_xslt = yes; then
      AC_CHECK_LIB(xslt, xsltApplyStylesheet, xslt_ok=yes, xslt_ok=no)
      if test "$xslt_ok" = "yes"; then
	AC_CHECK_HEADER(libxslt/xslt.h, xslthdr_ok=yes, xslthdr_ok=no)
	if test "$xslthdr_ok" = "no"; then
	  xslt_ok=no
	fi
      fi
      if test "$xslt_ok" = "yes"; then
	HAVE_LIBXSLT=1
	AC_DEFINE(HAVE_LIBXSLT,1,[Define if libxslt available])
	LIBS="-lxslt $LIBS"
      else
        SETUP_ERRORS="$SETUP_ERRORS W108"
      fi
    else
      HAVE_LIBXSLT=0
      AC_MSG_WARN([Disabled support for XSLT funtionality.])
    fi
    AC_SUBST(HAVE_LIBXSLT)
  else
    HAVE_LIBXML=0
    # Restore the CFLAGS and LIBS because AM_PATH_XML messes them
    LIBS="$saved_LIBS"
    CFLAGS="$saved_CFLAGS"
    SETUP_ERRORS="$SETUP_ERRORS E107"
  fi
else
  AC_MSG_WARN([Disabled support for XML funtionality.])
  HAVE_LIBXML=0
fi
AC_SUBST(HAVE_LIBXML)

#--------------------------------------------------------------------
# Set Apple/Darwin/OSX/NeXT information for other tests
#--------------------------------------------------------------------
OBJC_RUNTIME_LIB=`echo $ac_cv_library_combo | awk -F- '{print $1}'`
AC_MSG_CHECKING(the Objective-C runtime)
if test "$OBJC_RUNTIME_LIB" = "nx" -o "$OBJC_RUNTIME_LIB" = "apple"; then
  AC_MSG_RESULT(NeXT)
  LIBOBJC='-lobjc'
  OBJCFLAGS="-fnext-runtime -DNeXT_RUNTIME"
else
  AC_MSG_RESULT(GNU)
  LIBOBJC='-lobjc'
  OBJCFLAGS="-fgnu-runtime"
fi

#--------------------------------------------------------------------
# Check OpenSSL for HTTPS support.
#--------------------------------------------------------------------
  ssl_ok=no
  AC_CHECK_HEADERS(openssl/ssl.h)
  if test $ac_cv_header_openssl_ssl_h = yes; then
    AC_CHECK_LIB(crypto, CRYPTO_malloc)
    if test $ac_cv_lib_crypto_CRYPTO_malloc = yes; then
      # ssl needs socket on Solaris
      AC_CHECK_LIB(socket, main)
      AC_CHECK_LIB(ssl, ssl2_clear)
      AC_CHECK_LIB(cipher,des_setkey)
      if test $ac_cv_lib_ssl_ssl2_clear = yes; then
        ssl_ok=yes
      fi
    fi
  fi

if test $ssl_ok = no; then
  SETUP_ERRORS="$SETUP_ERRORS W125"

fi

#--------------------------------------------------------------------
# Check for X
#--------------------------------------------------------------------
AC_PATH_XTRA 
if test "x$no_x" = xyes -a $MINGW32 = no; then
  SETUP_ERRORS="$SETUP_ERRORS E127"
fi


#--------------------------------------------------------------------
# Check if Objective-C is installed
#--------------------------------------------------------------------
AC_MSG_CHECKING(for Objective-C compiler)
cc1objpath=`gcc -print-prog-name=cc1obj`
if test "$cc1objpath" != "cc1obj"; then
  AC_MSG_RESULT(yes)
else
  SETUP_ERRORS="$SETUP_ERRORS E150"
  AC_MSG_RESULT(no)
fi

AC_CHECK_HEADERS(objc/objc.h)
if test $ac_cv_header_objc_objc_h = no; then
  SETUP_ERRORS="$SETUP_ERRORS E151"
fi


#-------------------------------------------------------------------
# Check to see what parts of GNUstep are installed
#-------------------------------------------------------------------
GNUSTEP_INSTALLED=no
AC_MSG_CHECKING(if GNUstep environment exists)
if test -n "$GNUSTEP_SYSTEM_ROOT"; then
  AC_MSG_RESULT($GNUSTEP_SYSTEM_ROOT)
else
  AC_MSG_RESULT(no)
fi
AC_MSG_CHECKING(if GNUstep directories exists)
if test -d $GNUSTEP_SYSTEM_ROOT -a -f $GNUSTEP_SYSTEM_ROOT/Library/Makefiles/GNUstep.sh; then
  AC_MSG_RESULT(yes)
  GNUSTEP_INSTALLED=yes
else
  AC_MSG_RESULT(no)
  SETUP_ERRORS="$SETUP_ERRORS I199"  
fi
AC_SUBST(GNUSTEP_INSTALLED)
		   
#--------------------------------------------------------------------
# Miscellaneous flags
#--------------------------------------------------------------------
# Set location of GNUstep dirs for later use
GNUSTEP_HDIR=
gnustep_flattened=1
if test $GNUSTEP_INSTALLED = yes; then
  GNUSTEP_HDIR=$GNUSTEP_SYSTEM_ROOT/Library/Headers
  gnustep_flattened=[`grep GNUSTEP_FLATTENED=yes $GNUSTEP_SYSTEM_ROOT/Library/Makefiles/GNUstep.sh | wc -l | tr -d ' '`]
  if test $gnustep_flattened = 1; then
    GNUSTEP_LDIR=$GNUSTEP_SYSTEM_ROOT/Library/Libraries
  else
    clean_target_os=`$GNUSTEP_SYSTEM_ROOT/Library/Makefiles/clean_os.sh $target_os`
    clean_target_cpu=`$GNUSTEP_SYSTEM_ROOT/Library/Makefiles/clean_cpu.sh $target_cpu`
    obj_dir=$clean_target_cpu/$clean_target_os
    GNUSTEP_LDIR=$GNUSTEP_SYSTEM_ROOT/Library/Libraries/$obj_dir/
  fi
fi

# Check to see if the libobjc library is in our GNUSTEP_SYSTEM_ROOT.
# If so, there are probably other libraries that we want there also, so
# leave the proper includes in CPPFLAGS and LDFLAGS
GS_CUSTOM_OBJC=NONE
AC_MSG_CHECKING(for GNUstep up-to-date objc library)
gs_cv_objc_libdir=NONE
if test -f "$GNUSTEP_HDIR/objc/objc.h"; then
  if test -f "$GNUSTEP_LDIR/libobjc.a" -o -f "$GNUSTEP_LDIR/libobjc.so"; then
    gs_cv_objc_libdir=$GNUSTEP_LDIR
  else
    gs_cv_objc_libdir=NONE
  fi
  GS_CUSTOM_OBJC=$gs_cv_objc_libdir
fi
gcc_shared_libobjc=`gcc -print-file-name=libobjc.so`
if test -f "$gcc_shared_libobjc"; then
  gs_cv_objc_libdir=`dirname $gcc_shared_libobjc`
fi
AC_MSG_RESULT($gs_cv_objc_libdir)

saved_CPPFLAGS="$CPPFLAGS"
saved_LDFLAGS="$LDFLAGS"
if test "$gs_cv_objc_libdir" = "$GNUSTEP_LDIR"; then
  # The following are needed to compile the test programs
  CPPFLAGS="$CPPFLAGS -I$GNUSTEP_SYSTEM_ROOT/Library/Headers"
  LDFLAGS="$LDFLAGS -L$gs_cv_objc_libdir"

  # And the following to execute them
  LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$gs_cv_objc_libdir"
  export LD_LIBRARY_PATH
fi

#--------------------------------------------------------------------
# Check for FFI interface libraries for invocations
#--------------------------------------------------------------------
enable_ffcall=yes
enable_libffi=no
AC_CHECK_HEADER(ffi.h, have_libffi=yes, have_libffi=no)
AC_CHECK_HEADERS(callback.h, have_ffcall=yes, have_ffcall=no)
if test $have_ffcall = no; then
  enable_ffcall=no
  # If we don't have ffcall but do have libffi, use libffi
  if test $have_libffi = yes; then
    enable_libffi=yes
  fi
fi
if test $have_libffi = no; then
  enable_libffi=no
fi

have_forward_hook=yes
saved_CPPFLAGS="$CPPFLAGS"
CPPFLAGS="$CPPFLAGS $OBJCFLAGS -x objective-c"
AC_MSG_CHECKING("for forwarding callback in runtime")
AC_COMPILE_IFELSE([#include "$srcdir/config/config.forward.m"],
	have_forward_hook=yes, have_forward_hook=no)
AC_MSG_RESULT($have_forward_hook)
if test $have_forward_hook = no; then
  enable_libffi=no
  enable_ffcall=no
fi
CPPFLAGS="$saved_CPPFLAGS"

AC_MSG_CHECKING("FFI library usage")
if test $enable_libffi = yes; then
  saved_LIBS="$LIBS"
  LIBS="-lffi $LIBS"
  AC_TRY_LINK([#include <ffi.h>], ,ffi_ok="yes", ffi_ok="no")
  if test $ffi_ok = yes; then
    AC_MSG_RESULT(libffi)
  else
    LIBS="$saved_LIBS"
  fi
elif test $enable_ffcall = yes; then
  saved_LIBS="$LIBS"
  LIBS="-lcallback -lavcall $LIBS"
  AC_TRY_LINK([#include <callback.h>], , ffi_ok="yes", ffi_ok="no")
  if test $ffi_ok = yes; then
    AC_MSG_RESULT(ffcall)
  else
    LIBS="$saved_LIBS"
  fi
else
  ffi_ok=no
fi

if test $ffi_ok = no; then
  AC_MSG_RESULT(none)
  if test $have_forward_hook = no; then
    # Need the warning for MingW when libobjc is moved out of the way
    SETUP_ERRORS="$SETUP_ERRORS W272"
  else
    SETUP_ERRORS="$SETUP_ERRORS W270"
  fi
fi

if test "`echo $host_os|sed 's/[[0-9]].*//'`" = darwin -a $host_cpu = "powerpc" -a $ac_cv_header_ffi_h = no; then
  SETUP_ERRORS="$SETUP_ERRORS E155"
fi

#--------------------------------------------------------------------
# Check if libobjc was compiled with thread support. (from gnustep-make)
#--------------------------------------------------------------------
OBJC_THREAD=
AC_ARG_WITH(thread-lib,
[--with-thread-lib		Specify alternate thread library],
OBJC_THREAD=$withval,
OBJC_THREAD=
)


AC_MSG_CHECKING(whether objc has thread support)
saved_CFLAGS="$CFLAGS"
saved_LIBS="$LIBS"
CFLAGS="$CFLAGS -x objective-c -I$srcdir $OBJCFLAGS"
if test "$OBJC_THREAD" != ""; then
  LIBS="-lobjc $LIBS $OBJC_THREAD"
  AC_TRY_RUN([#include "$srcdir/config/config_thread.m"], 
	objc_threaded="$OBJC_THREAD",
	objc_threaded="", objc_threaded="")
elif test "$host_os" = linux-gnu; then
  LIBS="-lobjc -lpthread"
  AC_TRY_RUN([#include "$srcdir/config/config_thread.m"], objc_threaded="-lpthread",
	objc_threaded="", objc_threaded="-lpthread")
elif test "`echo $host_os|sed 's/[[0-9]].*//'|sed s/elf//`" = freebsd; then
  LIBS="-pthread -lobjc"
  AC_TRY_RUN([#include "$srcdir/config/config_thread.m"], objc_threaded="-pthread",
       objc_threaded="", objc_threaded="-pthread")
  if test x"$objc_threaded" = x""; then
    LIBS="-lpthread -lobjc"
    AC_TRY_RUN([#include "$srcdir/config/config_thread.m"], objc_threaded="-lpthread",
	objc_threaded="", objc_threaded="-lpthread")
  fi
  if test x"$objc_threaded" = x""; then
    LIBS="-lobjc -lpcthread"
    AC_TRY_RUN([#include "$srcdir/config/config_thread.m"], objc_threaded="-lpcthread",
	objc_threaded="", objc_threaded="-lpcthread")
  fi
elif test "$MINGW32" = yes; then
  # Mingw doesn't need anything extra for threads
  LIBS="-lobjc $LIBS"
  AC_TRY_RUN([#include "$srcdir/config/config_thread.m"], 
	objc_threaded="works",
	objc_threaded="", objc_threaded="works")
else
  LIBS="-lobjc $LIBS"
  AC_TRY_RUN([#include "$srcdir/config/config_thread.m"], 
	objc_threaded="works",
	objc_threaded="", objc_threaded="")
  if test x"$objc_threaded" = x""; then
    LIBS="-lobjc $saved_LIBS -lpthread "
    AC_TRY_RUN([#include "$srcdir/config/config_thread.m"], 
    	objc_threaded="-lpthread", 
	objc_threaded="", objc_threaded="")
  fi
  if test x"$objc_threaded" = x""; then
    # Solaris, OpenBSD/sparc
    LIBS="-lobjc $saved_LIBS -lpthread -lposix4"
    AC_TRY_RUN([#include "$srcdir/config/config_thread.m"], 
    	objc_threaded="-lpthread -lposix4", 
	objc_threaded="", objc_threaded="")
  fi
  if test x"$objc_threaded" = x""; then
    LIBS="-lobjc $saved_LIBS -lthread "
    AC_TRY_RUN([#include "$srcdir/config/config_thread.m"], 
    	objc_threaded="-lthread", 
	objc_threaded="", objc_threaded="")
  fi
fi
if test x"$objc_threaded" = x""; then
  AC_MSG_RESULT(no)
else
  if test x"$objc_threaded" = x"works"; then
    objc_threaded=""
  fi
  AC_MSG_RESULT(yes: $objc_threaded)
fi
ac_cv_objc_threaded="$objc_threaded"
AC_SUBST(objc_threaded)
AC_SUBST(ac_cv_objc_threaded)
# Restore LIBS and CFLAGS
LIBS="$saved_LIBS"
CFLAGS="$saved_CFLAGS"

#--------------------------------------------------------------------
# Check whether Objective-C /really/ works
#--------------------------------------------------------------------
AC_MSG_CHECKING(whether objc really works)
saved_CPPFLAGS="$CPPFLAGS"
saved_LIBS="$LIBS"
CPPFLAGS="$CPPFLAGS -x objective-c $OBJCFLAGS"
LIBS="$LIBS $LIBOBJC $objc_threaded"		    
AC_CACHE_VAL(objc_works,
  AC_TRY_RUN([#include "$srcdir/config/config.objc.m"],
  objc_works=yes, 
  objc_works=no, 
  objc_works=yes)
)
if test $objc_works = yes; then
  AC_MSG_RESULT(yes)
else
  AC_MSG_RESULT(no)
  if test "$gs_cv_gcc_major_version" = 3 -a "$gs_cv_gcc_minor_version" = 0; then
    SETUP_ERRORS="$SETUP_ERRORS E280"
  elif test "$MINGW32" = no -a "$CYGWIN" = no; then
    SETUP_ERRORS="$SETUP_ERRORS E281"
  fi
fi

LIBS="$saved_LIBS"
CPPFLAGS="$saved_CPPFLAGS"

#--------------------------------------------------------------------
# GUI/Graphic library Depends
#--------------------------------------------------------------------
AC_CHECK_LIB(m, main)

#--------------------------------------------------------------------
# Find JPEG
#--------------------------------------------------------------------
CPPFLAGS="$with_jpeg_include ${CPPFLAGS}"
LDFLAGS="$with_jpeg_library ${LDFLAGS}"
AC_CHECK_HEADERS(jpeglib.h, have_jpeg=yes, have_jpeg=no)
AC_CHECK_LIB(jpeg, jpeg_destroy_decompress)
have_jpeg_lib=no
if test "$ac_cv_lib_jpeg_jpeg_destroy_decompress" = yes; then
  have_jpeg_lib=yes
fi
if test "$have_jpeg" = no; then
  if test "$have_jpeg_lib" = yes; then
    SETUP_ERRORS="$SETUP_ERRORS W402"
  else
    SETUP_ERRORS="$SETUP_ERRORS W403"
  fi
fi

#--------------------------------------------------------------------
# Find TIFF
#--------------------------------------------------------------------
AC_CHECK_LIB(z, main)
AC_CHECK_HEADER(tiffio.h, have_tiff=yes, have_tiff=no)
AC_CHECK_LIB(tiff, TIFFReadScanline)
have_tiff_lib=no
if test "$ac_cv_lib_tiff_TIFFReadScanline" = yes; then
  have_tiff_lib=yes
fi

if test "$have_tiff" = no; then
  if test "$have_tiff_lib" = yes; then
    SETUP_ERRORS="$SETUP_ERRORS E400"
  else
    SETUP_ERRORS="$SETUP_ERRORS E401"
  fi
fi

#--------------------------------------------------------------------
# Find additional image libs
#--------------------------------------------------------------------
AC_CHECK_HEADER(png.h, have_png=yes, have_png=no)
AC_CHECK_LIB(png, main)
if test "$have_png" = no; then
  if test "$ac_cv_lib_png_main" = yes; then
    SETUP_ERRORS="$SETUP_ERRORS W408"
  else
    SETUP_ERRORS="$SETUP_ERRORS W409"
  fi
fi

#--------------------------------------------------------------------
# Basic GNUstep installation
#--------------------------------------------------------------------
GNUSTEP_SOURCED=no
if test $GNUSTEP_INSTALLED = yes; then

  # GNUstep.sh sourced?
  if test -n "$GNUSTEP_HOST_OS" -a -n "$GNUSTEP_HOST_CPU"; then
    GNUSTEP_SOURCED=yes
  else
    SETUP_ERRORS="$SETUP_ERRORS W300"
  fi

  # gnustep libraries installed?
  saved_CPPFLAGS="$CPPFLAGS"
  CPPFLAGS="$CPPFLAGS -x objective-c -I$GNUSTEP_HDIR -I$GNUSTEP_HDIR/gnustep"
  if test $gnustep_flattened = 0; then
    CPPFLAGS="$CPPFLAGS -I$GNUSTEP_HDIR/$clean_target_cpu/$clean_target_os"
    # Also possible we are supporting multiple combos...
    CPPFLAGS="$CPPFLAGS -I$GNUSTEP_HDIR/$ac_cv_library_combo  -I$GNUSTEP_HDIR/$ac_cv_library_combo/$clean_target_cpu/$clean_target_os"
  fi
  AC_CHECK_HEADERS([Foundation/NSObject.h AppKit/NSApplication.h]) 

  CPPFLAGS="$saved_CPPFLAGS"

fi

#--------------------------------------------------------------------
# GNUstep Installed version
#--------------------------------------------------------------------
GNUSTEP_MAKE_VERSION=0
GNUSTEP_BASE_VERSION=0
GNUSTEP_GUI_VERSION=0
if test $GNUSTEP_INSTALLED = yes; then

  # Check the version of gnustep-make
  AC_MSG_CHECKING(GNUstep Make version)
  gversion=$GNUSTEP_SYSTEM_ROOT/Library/Makefiles/config.make
  if test $gnustep_flattened = 0; then
    gversion=$GNUSTEP_SYSTEM_ROOT/Library/Makefiles/$clean_target_cpu/$clean_target_os/config.make
  fi
  # Note: we need multiple [[ to get around autoconf's m4 processing
  GNUSTEP_MAKE_VERSION=[`grep GNUSTEP_MAKE_VERSION $gversion | sed "s/.*=\([0-9.]\)/\1/"`]
  AC_MSG_RESULT($GNUSTEP_MAKE_VERSION)

  AC_MSG_CHECKING(GNUstep Base version)
  if test $ac_cv_header_Foundation_NSObject_h = yes; then
    gversion=$GNUSTEP_SYSTEM_ROOT/Library/Libraries/Resources/gnustep-base/Info-gnustep.plist
    if test -f $gversion ; then
      GNUSTEP_BASE_VERSION=[`grep GSBundleShortVersionString $gversion | sed "s/.*\"\([0-9.]\)/\1/;s/\";//"`]
    else
      GNUSTEP_BASE_VERSION=0.0.0
    fi
  fi
  AC_MSG_RESULT($GNUSTEP_BASE_VERSION)

  AC_MSG_CHECKING(GNUstep Gui version)
  if test $ac_cv_header_AppKit_NSApplication_h = yes; then
    gversion=$GNUSTEP_SYSTEM_ROOT/Library/Libraries/Resources/gnustep-gui/Info-gnustep.plist
    if test -f $gversion ; then
      GNUSTEP_GUI_VERSION=[`grep GSBundleShortVersionString $gversion | sed "s/.*\"\([0-9.]\)/\1/;s/\";//"`]
      GNUSTEP_GUI_INTERFACE=[`grep GSBundleVersion $gversion | sed "s/.*= \([0-9]\)/\1/;s/.[0-9];//"`]
    else
      GNUSTEP_GUI_VERSION=0.0.0
      GNUSTEP_GUI_INTERFACE=
    fi
  fi
  AC_MSG_RESULT($GNUSTEP_GUI_VERSION)

fi

  AC_MSG_CHECKING(GNUstep Back)
  if test -z "$GNUSTEP_GUI_INTERFACE"; then
    BUNDLE_NAME=libgnustep-back
  else
    BUNDLE_NAME=libgnustep-back-$GNUSTEP_GUI_INTERFACE
  fi
  have_back=no
  if test -f $GNUSTEP_SYSTEM_ROOT/Library/Bundles/$BUNDLE_NAME.bundle/$BUNDLE_NAME; then
    have_back=yes
    AC_MSG_RESULT($BUNDLE_NAME)
  else
    AC_MSG_RESULT(none)
  fi

AC_SUBST(GNUSTEP_SYSTEM_ROOT)
AC_SUBST(GNUSTEP_SOURCED)
AC_SUBST(GS_CUSTOM_OBJC)
AC_SUBST(ac_cv_header_callback_h)
AC_SUBST(ac_cv_header_ffi_h)
AC_SUBST(ac_cv_header_AppKit_NSApplication_h)
AC_SUBST(ac_cv_header_Foundation_NSObject_h)
AC_SUBST(have_back)
AC_SUBST(SETUP_ERRORS)
AC_SUBST(GNUSTEP_MAKE_VERSION)
AC_SUBST(GNUSTEP_BASE_VERSION)
AC_SUBST(GNUSTEP_GUI_VERSION)
AC_SUBST(GNUSTEP_GUI_INTERFACE)
AC_SUBST(gnustep_flattened)

#--------------------------------------------------------------------
# Produce the output files
#--------------------------------------------------------------------
#AC_CONFIG_TESTDIR([tests])
AC_CONFIG_FILES([setupvars])
#AC_CONFIG_FILES([tests/Makefile tests/atlocal])

AC_CONFIG_COMMANDS([default],
	[[chmod a+x setupvars]],
	[[]])
AC_OUTPUT
