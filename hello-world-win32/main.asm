include 'win64ax.inc'

_start:
  invoke MessageBox, NULL, 'Hello, world', 'A simple message box', MB_ICONINFORMATION + MB_OK
  invoke ExitProcess, 0
