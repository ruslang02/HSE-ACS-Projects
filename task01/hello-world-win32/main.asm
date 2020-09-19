format PE GUI 4.0

include 'win32ax.inc'

_start:
  invoke MessageBox, NULL, 'Hello, world', 'A simple message box', MB_OK
  invoke ExitProcess, 0
.end _start