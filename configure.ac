#
#   configure.ac
#
#   Copyright (C) 202 Free Software Foundation, Inc.
#
#   Written: Adam Fedor <fedor@gnu.org>
#   Date: May 2002
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
AC_INIT([GNUstep Setup], 1.0.0, [bug-gnustep@gnu.org])
AC_PREREQ(2.57)

# From gnustep-base
builtin(include, config/objc-con-autoload.m4)dnl
builtin(include, config/objc-sys-dynamic.m4)dnl

SETUP_ERRORS=

AC_CANONICAL_TARGET([])
AM_INIT_AUTOMAKE
AC_CONFIG_SRCDIR([InstallGNUstep])
AM_CONFIG_HEADER(config.h)

#--------------------------------------------------------------------
# GNUstep location
#
# The user should have the GNUSTEP_SYSTEM_ROOT environment variable
# defined, but if not then we have a global default.
# Also test for the C: directory, which means we're on Windows
#--------------------------------------------------------------------
AC_PREFIX_DEFAULT(`if test "x$GNUSTEP_SYSTEM_ROOT" = "x"; then 
  if test -d C: ; then
    echo C:/GNUstep;
  else
    echo /usr/GNUstep ;
  fi
else
  echo "$GNUSTEP_SYSTEM_ROOT" ;
fi`)
if test "x$prefix" = "xNONE"; then
  prefix="$ac_default_prefix" ;
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
	        INCLUDES="$INCLUDES -I/usr/local/include"
		LIB_DIR="$LIB_DIR -L/usr/local/lib";;
  netbsd*)	INCLUDES="$INCLUDES -I/usr/pkg/include"
		LIB_DIR="$LIB_DIR -Wl,-R/usr/pkg/lib -L/usr/pkg/lib";;
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
# Find the binary and compile tools
#--------------------------------------------------------------------
AC_CHECK_PROG(AR, ar, ar)
AC_CHECK_PROG(LD, ld, ld)
AC_CHECK_PROG(DLLTOOL, dlltool, dlltool)
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
  ld_version=[`ld --version | grep "[0-9]\.[0-9]" | sed "s/\(^[^0-9]*\)\([0-9]\.[0-9][0-9]*\)\([^0-9].*\)/\2/" 2>\dev\null`]
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
iconv_version=[`iconv -V | grep "[0-9]\.[0-9]" | sed "s/\(^[^0-9]*\)\([0-9]\.[0-9][0-9]*\)\([^0-9].*\)/\2/"`]
if test -n "$iconv_version" -a "$iconv_version" \> 2.1; then
  AC_MSG_RESULT(yes $iconv_version)
else
  AC_MSG_RESULT(no $iconv_version)
  case $host_os in
    *darwin*)
      ;;
    *solaris*)
      ;;
    *)
      SETUP_ERRORS="$SETUP_ERRORS I106";;
  esac
fi

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
# Type size information needed for foundation headers.
#--------------------------------------------------------------------
AC_CHECK_SIZEOF(void*)

GS_SINT8="signed char"
GS_UINT8="unsigned char"
AC_SUBST(GS_SINT8)
AC_SUBST(GS_UINT8)

AC_CHECK_SIZEOF(short)
AC_SUBST(ac_cv_sizeof_short)

AC_CHECK_SIZEOF(int)
AC_SUBST(ac_cv_sizeof_int)

AC_CHECK_SIZEOF(long)
AC_SUBST(ac_cv_sizeof_long)

AC_CHECK_SIZEOF(long long)
AC_SUBST(ac_cv_sizeof_long_long)

AC_CHECK_SIZEOF(float)
AC_SUBST(ac_cv_sizeof_float)

AC_CHECK_SIZEOF(double)
AC_SUBST(ac_cv_sizeof_double)

AC_SUBST(ac_cv_sizeof_voidp)
if test $ac_cv_sizeof_voidp = $ac_cv_sizeof_int; then
  GS_ADDR="unsigned int"
else
  if test $ac_cv_sizeof_voidp = $ac_cv_sizeof_long; then
    GS_ADDR="unsigned long"
  else
    if test $ac_cv_sizeof_voidp = $ac_cv_sizeof_long_long; then
      GS_ADDR="unsigned long long"
    else
      SETUP_ERRORS="$SETUP_ERRORS E140"
    fi
  fi
fi
AC_SUBST(GS_ADDR)

if test $ac_cv_sizeof_short = 2; then
  GS_SINT16="signed short"
  GS_UINT16="unsigned short"
else
  if test $ac_cv_sizeof_int = 2; then
    GS_SINT16="signed int"
    GS_UINT16="unsigned int"
  else
    SETUP_ERRORS="$SETUP_ERRORS E141"
  fi
fi
AC_SUBST(GS_SINT16)
AC_SUBST(GS_UINT16)

if test $ac_cv_sizeof_int = 4; then
  GS_SINT32="signed int"
  GS_UINT32="unsigned int"
else
  if test $ac_cv_sizeof_long = 4; then
    GS_SINT32="signed long"
    GS_UINT32="unsigned long"
  else
    if test $ac_cv_sizeof_short = 4; then
      GS_SINT32="signed short"
      GS_UINT32="unsigned short"
    else
      SETUP_ERRORS="$SETUP_ERRORS E142"
    fi
  fi
fi
AC_SUBST(GS_SINT32)
AC_SUBST(GS_UINT32)

if test $ac_cv_sizeof_float = 4; then
  GS_FLT32="float"
else
  SETUP_ERRORS="$SETUP_ERRORS E143"
fi
AC_SUBST(GS_FLT32)

if test $ac_cv_sizeof_double = 8; then
  GS_FLT64="double"
else
  SETUP_ERRORS="$SETUP_ERRORS E144"
fi
AC_SUBST(GS_FLT64)

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
if test -d $prefix -a -f $prefix/Library/Makefiles/GNUstep.sh; then
  AC_MSG_RESULT(yes)
  GNUSTEP_INSTALLED=yes
elif test -n "$GNUSTEP_SYSTEM_ROOT" -a -d "$GNUSTEP_SYSTEM_ROOT"; then
  AC_MSG_RESULT(not where we want them)
  SETUP_ERRORS="$SETUP_ERRORS I190 I199"  
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
if test $GNUSTEP_INSTALLED = yes; then
  GNUSTEP_HDIR=$GNUSTEP_SYSTEM_ROOT/Library/Headers
  if test "$GNUSTEP_FLATTENED" = yes; then
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
  CPPFLAGS="$CPPFLAGS -I$prefix/Library/Headers"
  LDFLAGS="$LDFLAGS -L$gs_cv_objc_libdir"

  # And the following to execute them
  LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$gs_cv_objc_libdir"
  export LD_LIBRARY_PATH
fi

#--------------------------------------------------------------------
# Check for FFI interface libraries for invocations
#--------------------------------------------------------------------
AC_CHECK_HEADERS(ffi.h callback.h)

AC_MSG_CHECKING(for forwarding callback in runtime)
AC_EGREP_HEADER(__objc_msg_forward, objc/objc-api.h, have_msg_forward=yes, 
	        have_msg_forward=no)
if test $have_msg_forward = yes; then
  AC_MSG_RESULT(yes)
else
  AC_MSG_RESULT(no)
fi
AC_DEFINE(have_msg_forward,,
	  [Define if you have the _objc_msg_forward function in libobjc])
AC_MSG_CHECKING(FFI library usage)
WITH_FFI=none
if test $have_msg_forward = yes; then
  if test $ac_cv_header_callback_h = yes -o $ac_cv_header_ffi_h = yes; then
    AC_MSG_RESULT(yes)
  else
    AC_MSG_RESULT(no)
  fi
else
    AC_MSG_RESULT(no)
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
# Setup dynamic linking 
#--------------------------------------------------------------------
OBJC_SYS_DYNAMIC_LINKER()

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
  else  
    SETUP_ERRORS="$SETUP_ERRORS E281"
  fi
fi

# Don't revert any Objective-C flags as they are used in the next test

#---------------------------------------------------------------------
# Guess if we are using a compiler which has the (GNU extension) +load 
# method which is executed before main.  
# Defines HAVE_LOAD_METHOD if +load methods are called before main.
# Needed by NSProcessInfo.m
#---------------------------------------------------------------------
AC_MSG_CHECKING(if +load method is executed before main)
AC_CACHE_VAL(objc_load_method_worked,
  AC_TRY_RUN([#include "$srcdir/config/config.loadtest.m"],
	objc_load_method_worked=yes,
	objc_load_method_worked=no,
	objc_load_method_worked=no)
)
if test $objc_load_method_worked = yes; then
  AC_DEFINE(HAVE_LOAD_METHOD,,
            [Define if your Obj-C compiler calls +load methods before main])
  AC_MSG_RESULT(yes)
else
  AC_MSG_RESULT(no)
fi

#---------------------------------------------------------------------
# Guess if we are using a compiler which allows us to change the class
# to be used for constant strings by using the -fconstant-string-class
# option.  If that is the case, we change it to NSConstantString.
#---------------------------------------------------------------------
string_saved_CPPFLAGS="$CPPFLAGS"
CPPFLAGS="$CPPFLAGS -fconstant-string-class=FooConstantString"
AC_MSG_CHECKING(if the compiler supports -fconstant-string-class)
AC_CACHE_VAL(objc_compiler_supports_constant_string_class,
  AC_TRY_RUN([#include "$srcdir/config/config.constant-string-class.m"],
  objc_compiler_supports_constant_string_class=yes,
  objc_compiler_supports_constant_string_class=no,
  objc_compiler_supports_constant_string_class=no)
)
if test $objc_compiler_supports_constant_string_class = yes; then
  NX_CONST_STRING_CPPFLAGS="-fconstant-string-class=NSConstantString"
  NX_CONST_STRING_CLASS=NSConstantString
  AC_MSG_RESULT(yes)
else
  NX_CONST_STRING_CPPFLAGS=""
  NX_CONST_STRING_CLASS=NXConstantString
  AC_MSG_RESULT(no)
fi
CPPFLAGS="$string_saved_CPPFLAGS"

AC_SUBST(NX_CONST_STRING_CPPFLAGS)
AC_SUBST(NX_CONST_STRING_CLASS)

LIBS="$saved_LIBS"
CPPFLAGS="$saved_CPPFLAGS"

#--------------------------------------------------------------------
# Gui Depends
#--------------------------------------------------------------------
AC_CHECK_LIB(m, main)

#--------------------------------------------------------------------
# Find JPEG
#--------------------------------------------------------------------
GRAPHIC_CFLAGS=
GRAPHIC_LFLAGS=

AC_ARG_WITH(jpeg_library, 
           [  --with-jpeg-library=DIR JPEG library file are in DIR], ,
           with_jpeg_library=)
AC_ARG_WITH(jpeg_include,  
	[  --with-jpeg-include=DIR JPEG include files are in DIR], ,
        with_jpeg_include=)

if test -n "$with_jpeg_library"; then
  with_jpeg_library="-L$with_jpeg_library"
fi
if test -n "$with_jpeg_include"; then
  with_jpeg_include="-I$with_jpeg_include"
fi

CPPFLAGS="$with_jpeg_include ${CPPFLAGS}"
LDFLAGS="$with_jpeg_library ${LDFLAGS}"
AC_CHECK_HEADERS(jpeglib.h, have_jpeg=yes, have_jpeg=no)
if test "$have_jpeg" = yes; then
  AC_CHECK_LIB(jpeg, jpeg_destroy_decompress)
  if test "$ac_cv_lib_jpeg_jpeg_destroy_decompress" = yes; then
    GRAPHIC_LFLAGS="$with_jpeg_library $GRAPHIC_LFLAGS"
    GRAPHIC_CFLAGS="$with_jpeg_include $GRAPHIC_CFLAGS"
  fi
fi
if test "$have_jpeg" = no; then
  SETUP_ERRORS="$SETUP_ERRORS W403"
fi


#--------------------------------------------------------------------
# Find TIFF
#--------------------------------------------------------------------
AC_ARG_WITH(tiff_library, 
           [  --with-tiff-library=DIR TIFF library file are in DIR], ,
           with_tiff_library=)
AC_ARG_WITH(tiff_include,  
	[  --with-tiff-include=DIR TIFF include files are in DIR], ,
        with_tiff_include=)

if test -n "$with_tiff_library"; then
  with_tiff_library="-L$with_tiff_library"
fi
if test -n "$with_tiff_include"; then
  with_tiff_include="-I$with_tiff_include"
fi

CPPFLAGS="$with_tiff_include ${CPPFLAGS}"
LDFLAGS="$with_tiff_library ${LDFLAGS}"
AC_CHECK_LIB(z, main)
AC_CHECK_HEADER(tiffio.h, have_tiff=yes, have_tiff=no)
if test "$have_tiff" = yes; then
  AC_CHECK_LIB(tiff, TIFFReadScanline)
  if test "$ac_cv_lib_tiff_TIFFReadScanline" = yes; then
    GRAPHIC_LFLAGS="$with_tiff_library $GRAPHIC_LFLAGS"
    GRAPHIC_CFLAGS="$with_tiff_include $GRAPHIC_CFLAGS"
  else
    have_tiff=no
  fi
fi

if test "$have_tiff" = no; then
  SETUP_ERRORS="$SETUP_ERRORS E401"
fi

#--------------------------------------------------------------------
# Find additional image libs
#--------------------------------------------------------------------
AC_CHECK_LIB(png, main)
if test "$ac_cv_lib_png_main" = no; then
  SETUP_ERRORS="$SETUP_ERRORS W409"
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
  CPPFLAGS="$CPPFLAGS -x objective-c -I$prefix/Library/Headers -I$prefix/Library/Headers/gnustep -I$prefix/Library/Headers/$clean_target_cpu/$clean_target_os"
  AC_CHECK_HEADERS([Foundation/NSObject.h AppKit/NSApplication.h]) 

  have_back=no
  if test -f $GNUSTEP_SYSTEM_ROOT/Library/Bundles/libgnustep-back.bundle/libgnustep-back; then
    have_back=yes
  fi
  CPPFLAGS="$saved_CPPFLAGS"

fi

AC_SUBST(GNUSTEP_SOURCED)
AC_SUBST(GS_CUSTOM_OBJC)
AC_SUBST(ac_cv_header_callback_h)
AC_SUBST(ac_cv_header_ffi_h)
AC_SUBST(ac_cv_header_AppKit_NSApplication_h)
AC_SUBST(ac_cv_header_Foundation_NSObject_h)
AC_SUBST(have_back)
AC_SUBST(SETUP_ERRORS)

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
