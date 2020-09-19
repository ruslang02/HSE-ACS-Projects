format ELF64
public _start
section '.data' writable
  ENTER_N db "Enter N: ", 0
  N dq ?
  ARRAY dd 10 dup(N)
section '.bss' writeable 
    _bss_char rb 1
    _buffer_char_size equ 2
    _buffer_char rb _buffer_char_size

    _buffer_number_size equ 21
    _buffer_number rb _buffer_number_size
section '.code' executable
  _start:
    mov rax, ENTER_N
    call str_print
    mov rax, N
    call input_number
    xor rcx, rcx
    xor rdx, rdx
    .next_item:
      mov rax, qword [ARRAY + rcx]
      call input_number
      add rcx, 4
      inc rdx
      cmp rdx, qword [N]
      jnz .next_item
    call exit
    ret
  exit:
    mov rax, 1
    mov rbx, 0
    int 80h

section '.str_func' executable
  str_len:
    xor rbx, rbx
    .next_char:
      add rbx, 1
      cmp [rax + rbx], byte 0
      jnz .next_char
    ret
  str_print:
    push rax
    call str_len
    push rbx
    mov rax, 4
    mov rbx, 1
    pop rdx
    pop rcx
    int 80h
    ret

section '.input_string' executable
; | input:
; rax = buffer
; rbx = buffer size
input_string:
    push rax
    push rbx
    push rcx
    push rdx

    mov rcx, rax
    mov rdx, rbx
    mov rax, 3 ; read
    mov rbx, 2 ; stdin
    int 0x80

    ; upd
    mov [rcx+rax-1], byte 0

    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret

section '.input_number' executable
; | output:
; rax = number
input_number:
    push rbx
    mov rax, _buffer_number
    mov rbx, _buffer_number_size
    call input_string
    call string_to_number
    pop rbx
    ret

section '.string_to_number' executable
; | input:
; rax = string
; | output:
; rax = number
string_to_number:
    push rbx
    push rcx
    push rdx
    xor rbx, rbx
    xor rcx, rcx
    .next_iter:
        cmp [rax+rbx], byte 0
        je .next_step
        mov cl, [rax+rbx]
        sub cl, '0'
        push rcx
        inc rbx
        jmp .next_iter
    .next_step:
        mov rcx, 1
        xor rax, rax
    .to_number:
        cmp rbx, 0
        je .close
        pop rdx
        imul rdx, rcx
        imul rcx, 10
        add rax, rdx
        dec rbx
        jmp .to_number
    .close:
        pop rdx
        pop rcx
        pop rbx
        ret
