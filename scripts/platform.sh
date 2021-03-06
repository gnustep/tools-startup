#
# Platform specific functions
#


gs_platform()
{
  gs_build=`$SRCDIR/config.guess` 2>&1
  if test -z "$gs_build"; then
    gs_build=unknown
  else
    gs_build=`$SRCDIR/config.sub $gs_build`
  fi
  if test -z "$gs_build"; then
    gs_build=unknown
  fi
  gs_build_cpu=`echo $gs_build | sed 's/^\([^-]*\)-\([^-]*\)-\(.*\)$/\1/'`
  gs_build_vendor=`echo $gs_build | sed 's/^\([^-]*\)-\([^-]*\)-\(.*\)$/\2/'`
  gs_build_os=`echo $gs_build | sed 's/^\([^-]*\)-\([^-]*\)-\(.*\)$/\3/'`
}

gs_platform_generic()
{
  GS_CPPFLAGS=
  GS_LDFLAGS=
  GS_PLATFORM_BUILD_OBJC=no
  GS_PLATFORM_NO_ROOT=no
  GS_FFI=libffi
  # For ffcall and non-gnustep packages
  GS_OTHER_CPPFLAGS=
}

gs_platform_cygwin()
{
  gs_platform_generic
  GS_PLATFORM_BUILD_OBJC=yes
  PKG_EXTRA_CONFIG="$PKG_EXTRA_CONFIG --disable-gsnd"
}

gs_platform_mingw()
{
  gs_platform_generic
  GS_PLATFORM_BUILD_OBJC=yes
  GS_PLATFORM_NO_ROOT=yes
  GS_FFI=libffi
  PKG_EXTRA_CONFIG="$PKG_EXTRA_CONFIG --disable-gsnd"
}

gs_platform_darwin()
{
  gs_platform_generic
  GS_FFI=libffi
  cc_dir=`which gcc`
  if [ -n "$CC" ]; then
    cc_dir=`which $CC`
  fi
  cc_dir=`dirname $cc_dir`
  if [ "$cc_dir" = "/opt/local/bin" ]; then
    # Use macports if available
    GS_CPPFLAGS="-I/opt/local/include"
    GS_LDFLAGS="-L/opt/local/lib"
    if [ \! -x /opt/local/bin/cups-config ]; then
      # 10.5 has cups in /usr/bin, which we don't want
      PKG_EXTRA_CONFIG="$PKG_EXTRA_CONFIG --disable-cups"
    fi
  fi
  if [ "$cc_dir" = "/sw/bin" ]; then
    # Fink is installed. Make sure to use this
    GS_CPPFLAGS="-I/sw/include"
    GS_LDFLAGS="-L/sw/lib"
    # aspell and glx sometimes link to Apple's libobjc. 
    # Fink's jpeg conflicts with Apple's
    PKG_GUI_CONFIG="--disable-aspell --disable-jpeg"
    PKG_BACK_CONFIG=--disable-glx
    if [ -d /sw/lib/freetype2/bin ]; then
      # We prefer the Fink freetyp2 lib to the X11R6 one
      # The X11R6 gives back erronous information from FTC_SBitCache_Lookup
      PATH=/sw/lib/freetype2/bin:$PATH
    fi
  fi
}

gs_platform_openbsd()
{
  gs_platform_generic
  if [ -d /usr/local/include/libpng ]; then
    GS_CPPFLAGS="-I/usr/local/include/libpng"
  fi
}

gs_platform_solaris()
{
  gs_platform_generic
  if [ -f /usr/local/include/tiff.h ]; then
    # Assume good tiff library is in /usr/local/lib
    GS_CPPFLAGS="-I/usr/local/include"
    GS_LDFLAGS="-L/usr/local/lib"
  fi
}

gs_platform_linuxgnu()
{
  gs_platform_generic
  GS_OTHER_CPPFLAGS=-fPIC
}

gs_platform_unknown()
{
  gs_platform_generic

  if [ -z "$CC" ]; then
    if [ -x /usr/bin/gcc3 ]; then
      CC=gcc3
      export CC
    fi
  fi
}

gs_flags()
{
  case "$gs_build_os" in
    darwin*)   gs_platform_darwin ;;
    solaris*)  gs_platform_solaris ;;
    cygwin*)   gs_platform_cygwin ;;
    mingw*)    gs_platform_mingw ;;
    openbsd*)  gs_platform_openbsd ;;
    *gnu*)     gs_platform_linuxgnu ;;
    *)         gs_platform_unknown ;;
  esac
}

gs_post_flags()
{
  if [ "$CC_APPLE" = yes ]; then
    if [ "x$LIBRARY_COMBO" != "xapple-apple-apple" ]; then
      GS_PLATFORM_BUILD_OBJC=yes
    fi
    CPPFLAGS="$CPPFLAGS -fnested-functions"
    PKG_GUI_CONFIG="--disable-gsnd"
  fi
}
