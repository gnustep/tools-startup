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
}

gs_platform_darwin()
{
  gs_platform_generic
  if [ -d /sw ]; then
    # Fink is installed. Make sure to use this
    GS_CPPFLAGS="-I/sw/include"
    GS_LDFLAGS="-L/sw/lib"
  fi
  if [ -d /sw/lib/freetype2/bin ]; then
    # We prefer the Fink freetyp2 lib to the X11R6 one
    PATH=/sw/lib/freetype2/bin:$PATH
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
    *)         gs_platform_unknown ;;
  esac
}
