#
# Common functions for GNUstep installer
#

gs_log_error()
{
  rm -f logs.tar.gz
  tar -cf logs.tar logs
  gzip logs.tar
  echo "---------------------------------------------------------"
  echo "Installation of $PKG_DISPLAY failed. Send the $BUILDDIR/logs.tar.gz"
  echo "file to bug-gnustep@gnu.org for help"
  echo "---------------------------------------------------------"
}

gs_build_package()
{
  echo "******** Installing $PKG_DISPLAY **********"
  rm -f logs/$PLOG*
  if [ $IS_CVS = no ]; then
    tar -zxf $SOURCESDIR/$PKG.tar.gz
  fi

  cd $PKG
  if [ "$PKG_DISPLAY" = "GNUstep Base" -a $NO_PRIV = yes ]; then
    echo Patching $PKG_DISPLAY to run in the home directory:
    patch -p0 < $SRCDIR/home-gdomap.patch
  fi
  if [ -f config.log ]; then
    make distclean
  fi
  if [ x"$PKG_CONFIG" != xNO ]; then
    ./configure $PKG_CONFIG $PKG_CPPFLAGS $PKG_LDFLAGS
    exitstatus=$?
    cp config.log ../logs/$PLOG-config.log
    if [ $exitstatus != 0 -o \! -f config.status ]; then
      unset exitstatus
      cd ..
      return
    fi
  fi
  $MAKE $MAKEFLAGS 2>&1 | tee ../logs/$PLOG.log
  tail -n 1 ../logs/$PLOG.log | grep Error
  if [ $? != 0 ]; then
    if [ $AS_ROOT = yes -o $HAVE_SUDO = no ]; then
      $MAKE $MAKEFLAGS install 2>&1 | tee ../logs/$PLOG-install.log
    else
      # Don't redirect stderr in case we need a password
      echo "**** Please enter password for sudo if directed: ****"
      sudo $MAKE $MAKEFLAGS install | tee ../logs/$PLOG-install.log
    fi
  fi
  cd ..
}
