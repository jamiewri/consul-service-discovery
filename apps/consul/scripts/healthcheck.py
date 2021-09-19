#!/usr/bin/env python

import subprocess
import sys

if __name__ == "__main__":

  cliArgs = sys.argv
  target = cliArgs[1]
  latency = cliArgs[2]
  command = 'curl -s ' + target + ' -w "%{time_total}"'
  process = subprocess.Popen(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE, universal_newlines=True, shell=True)
  stdout, stderr = process.communicate()
  rc = process.returncode

  output = stdout.split('\n')
  responseTime = float(output[-1])
  output.pop()
  response = output[0]

  if responseTime < float(latency):
   # sys.exit(0)
    for line in output:
      if "Home Page" in line:
        sys.exit(0)
      else:
        sys.exit(2)
  else:
    sys.exit(2)

