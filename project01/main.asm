format ELF64

public _start
section '.data' writable
  DESCRIPTION db "Ruslan Garifullin (https://github.com/ruslang02)", 10, "From a set of line segments (set by the coords of two points) find parallel ones.", 10, 10, 0
  M dq 4294967296
  M_N dq -4294967295
section '.bss' writeable 
    _bss_char rb 1
    _buffer_char_size equ 2
    _buffer_char rb _buffer_char_size

    _buffer_number_size equ 21
    _buffer_number rb _buffer_number_size

section '.code' executable
  _start:
    mov rax, DESCRIPTION
    call str_print
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
    push rbx
    push rcx
    push rdx
    push rax
    call str_len
    push rbx
    mov rax, 4
    mov rbx, 1
    pop rdx
    pop rcx
    int 80h
    pop rdx
    pop rcx
    pop rbx
    pop rax
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

section '.string_to_number' executable
; | input:
; rax = string
; | output:
; rax = number
string_to_number:
    push rbx
    push rcx
    push rdx
    push r11
    xor rbx, rbx
    xor rcx, rcx
    xor r11, r11
    cmp [rax], byte '-'
    je .toggle_invert
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
    .toggle_invert:
        mov r11, 1
        mov [rax], byte '0'
        jmp .next_iter
    .invert:
        push rbx
        xor r11, r11
        mov rbx, -1
        imul rbx
        pop rbx
    .close:
        cmp r11, 1
        je .invert
        pop r11
        pop rdx
        pop rcx
        pop rbx
        ret

section '.input_number' executable
; | output:
; rax = number
input_number:
    push rbx
    mov rax, _buffer_number
    mov rbx, _buffer_number_size
    call input_string
    cmp [rax], byte 0
    je .error
    call string_to_number
    jmp .exit
    .error:
      mov rax, [M_N]
    .exit:
      pop rbx
      ret