#
# Common functions for GNUstep installer
#

gs_log_error()
{
  rm -f logs.tar.gz
  cp setupvars logs
  tar -cf logs.tar logs
  gzip logs.tar
  echo "---------------------------------------------------------"
  echo "Installation of $PKG_DISPLAY failed. Send the $BUILDDIR/logs.tar.gz"
  echo "file to bug-gnustep@gnu.org for help"
  echo "---------------------------------------------------------"
  echo "Installation of $PKG_DISPLAY failed. Send the $BUILDDIR/logs.tar.gz" >&5
  echo "STOP" >&5
}

gs_patch_package()
{
  for file in $PKG_PATCHES __DONE__; do
    if [ $file != __DONE__ ]; then
      echo Applying patch $file
      echo Applying patch $file >&5
      # Assume unreversed patches to avoid undoing a patch when we run again.
      patch -f -p0 < $file >&5
    fi
  done
}

gs_build_package()
{
  echo "Building $PKG_DISPLAY ..." >&5
  echo "******** Building $PKG_DISPLAY **********"
  rm -f logs/$PLOG*
  if [ $IS_CVS = no ]; then
    tar -zxf $SOURCESDIR/$PKG.tar.gz
  fi

  if [ -n "$PKG_PATCHES" ]; then
    gs_patch_package
  fi
  cd $PKG
  # Clean the project, unless we are making from CVS
  if [ -f config.log -a $IS_CVS = no ]; then
    $MAKE distclean
  fi
  gsexitstatus=0
  if [ x"$PKG_CONFIG" != xNO ]; then
    echo ./configure ${PKG_CONFIG} >&5
    ./configure ${PKG_CONFIG}
    gsexitstatus=$?
    cp config.log ../logs/$PLOG-config.log
    if [ $gsexitstatus != 0 ]; then
      gsexitstatus=1
      cd ..
      return
    fi
  fi
  echo $MAKE $MAKEFLAGS >&5
  $MAKE $MAKEFLAGS 2>&1 | tee ../logs/$PLOG.log
  tail -5 ../logs/$PLOG.log | grep Error
  gserrorstatus=$?
  if [ $gserrorstatus != 0 ]; then
    echo $MAKE $MAKEFLAGS $PKG_INSTALL install >&5
    if [ $AS_ROOT = yes -o $HAVE_SUDO = no ]; then
      $MAKE $MAKEFLAGS $PKG_INSTALL install 2>&1 | tee ../logs/$PLOG-install.log
    else
      # Don't redirect stderr in case we need a password
      echo "**** Please enter password for sudo if directed: ****"
      sudo $MAKE $MAKEFLAGS $PKG_INSTALL install | tee ../logs/$PLOG-install.log
    fi
    tail -5 ../logs/$PLOG-install.log | grep Error
    gserrorstatus=$?
    if [ $gserrorstatus != 0 ]; then
      gsexitstatus=0
    else
      gsexitstatus=1
    fi
  else
    gsexitstatus=1
  fi
  cd ..
}
