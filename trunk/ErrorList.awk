BEGIN { doprint=0 }
{
  if ($1 == errid)
    doprint=1;
  else if ($1 == "" && doprint > 0)
    doprint=2;
  if (doprint == 1)
    print $0;
}
