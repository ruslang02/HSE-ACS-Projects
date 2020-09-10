format ELF64
public _start

section '.data' writeable
  ENTER_NAME db "Enter your name: ", 0
  YOUR_NAME db "Hey there, ", 0
  EXCLAMATION_MARK db "!", 10, 0

section '.bss'
  INPUT db ?

section '.text' executable
  _start:
    mov rax, ENTER_NAME
    call str_print

    call str_scan

    mov rax, INPUT
    call str_len

    add rbx, -1; navigate in the input
    mov [rax+rbx], byte 0; Replace \n with a \0 to prevent line breaks

    mov rax, YOUR_NAME
    call str_print

    mov rax, INPUT
    call str_print

    mov rax, EXCLAMATION_MARK
    call str_print

    call exit
    ret
  exit:
    mov rax, 1
    mov rbx, 0
    int 80h
    ret

section '.str_func' executable
  ; | input:
  ; rax = string
  str_print:
    call str_len
    mov rcx, rax
    mov rdx, rbx
    mov rax, 4
    mov rbx, 1
    int 80h
    ret

  ; | output:
  ; INPUT = input data
  str_scan:
    mov rcx, INPUT; variable
    mov rdx, 8; string length
    mov rax, 3; sys_read()
    mov rbx, 2; stdin
    int 80h
    ret
  ; | input:
  ; rax = string
  ; | output:
  ; rbx = length
  str_len:
    xor rbx, rbx
    .next_char:
      add rbx, 1
      cmp [rax + rbx], byte 0
      jnz .next_char
    ret