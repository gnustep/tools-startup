#
# Platform specific functions
#


gs_platform()
{
  gs_machine=`(uname -s) 2>/dev/null || echo unknown`
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
  case "$gs_machine" in
    Darwin*)   gs_platform_darwin ;;
    *)         gs_platform_unknown ;;
  esac
}