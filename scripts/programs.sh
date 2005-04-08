#
# Functions for finding programs

gs_check_error()
{
  rm -f logs.tar.gz
  tar -cf logs.tar logs
  gzip logs.tar
  echo "---------------------------------------------------------"
  echo "GNUstep check failed. Send the $BUILDDIR/logs.tar.gz"
  echo "file to bug-gnustep@gnu.org for help"
  echo "---------------------------------------------------------"
  echo "GNUstep check failed. Send the $BUILDDIR/logs.tar.gz" >&5
  echo "STOP" >&5
}

#--------------------------------------------------------------------
# Check ps
#--------------------------------------------------------------------
gs_find_ps()
{
  echo $ECHO_N "Checking ps... $ECHO_C"
  echo "Checking ps... " >&5
  PS=ps
  PSARGS=-axw
  $PS $PSARGS 2>&1 >&5
  if [ $? != 0 ]; then
    PSARGS=-e
    $PS $PSARGS 2>&1 >&5
    if [ $? != 0 ]; then
      echo no proper ps command found
      PS=:
    else
      echo ok
    fi
  else
    echo ok
  fi
  echo >&5
}

#--------------------------------------------------------------------
# Check program
#--------------------------------------------------------------------
gs_check_program()
{ 
  echo $ECHO_N "Checking $GSPROGRAM... $ECHO_C"
  echo "Checking $GSPROGRAM... " >&5

  rm -f $GSPROGRAMLOG
  which $GSPROGRAM >&5
  gs_exit_status=$?
  gs_out=`$PS $PSARGS | grep $GSPROGRAM | grep -v grep | wc -l | tr -d ' '`
  if test "$gs_out" = "1"; then
    echo already running
    echo already running >&5
  elif test $gs_exit_status != 0; then
    echo not found
    echo not found >&5
  else
    $GSPROGRAM $GSARGS 2>&1 | tee $GSPROGRAMLOG >&5
    gs_exit_status=$?
    if [ $gs_exit_status != 0 ]; then
      echo exec error
      echo exec error >&5
    else
      echo ok
      echo ok >&5
    fi
  fi

}