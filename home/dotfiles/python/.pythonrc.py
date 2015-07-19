# pythonrc.
try:
  import readline
  import rlcompleter
  import filecompleter
  pass
except ImportError, error_string:
  print 'ImportError: %s' % error_string
  pass
else:
  readline.parse_and_bind('tab: complete')
  readline.parse_and_bind("set input-meta on")
  readline.parse_and_bind("set convert-meta off")
  readline.parse_and_bind("set output-meta on")

  try:
    import os
    hist = os.path.join(os.environ['HOME'], '.pyhistory')

    if os.access(hist, os.F_OK) :
      readline.read_history_file(hist)
      pass

    import atexit
    atexit.register(readline.write_history_file, hist)

    del os, atexit

    pass
  except ImportError, errro_string:
    print 'ImportError: %s' % error_string
    pass
  pass
