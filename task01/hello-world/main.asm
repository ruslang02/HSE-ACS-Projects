format ELF64
public _start
section '.data' writeable
  msg_gen:
    msg db "Hello, world", 10, 0
    len = $-msg
section '.main' executable
  print_msg:
    mov rax, 4; sys_write()
    mov rbx, 1; >> stdout
    mov rcx, msg; message
    mov rdx, len; message length
    int 80h; system call
    ret; avoid endless loop
  _start:
    call print_msg
    mov rax, 1; sys_exit()
    mov rbx, 0; exit code - successful
    int 0x80; system call