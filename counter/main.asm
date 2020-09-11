; Я попытался реализовать вывод числа в консоль, но всё провалилось с треском
; Надо будет попробовать ещё...

format ELF64
public _start

section '.data' writeable
  _data:
    NEW_LINE db 10, 0
    WELCOME_MSG db "Welcome to the Counter app!", 10, 0
    NEW_ITEM_MSG db "Enter new item's price: ", 0
    STATUS_MSG db "Number of items: ", 0
    TOTAL_MSG db "It's time to pay! Total price: ", 0

    INPUT dq ?
    TOTAL rq 1
section '.bss' writeable 
    _bss_char rb 1
    _buffer_char_size equ 2
    _buffer_char rb _buffer_char_size

    _buffer_number_size equ 21
    _buffer_number rb _buffer_number_size
    
section '.main' executable
  exit:
    mov rax, 1
    mov rbx, 0
    int 80h
    ret
  _start:
    mov rax, WELCOME_MSG
    call str_print

    mov rax, STATUS_MSG
    call str_print

    mov rax, 0
    call print_number

    mov rax, NEW_LINE
    call str_print

    mov rax, NEW_ITEM_MSG
    call str_print

    call str_scan
    mov rax, INPUT
    call string_to_number
    call print_number

    ;mov rax, 567
    ;call num_print

    call exit
    ret

section '.num_func' executable
  ; | input:
  ; rax = number
  num_print:
    xor rbx, rbx
    .next_digit:
      xor rdx, rdx
      mov rcx, '10'
      div rcx
      call digit_print
      ;cmp eax, dword 0
      ;jne .next_digit
    ret
  ; | input:
  ; rdx = number
  digit_print:
    mov rax, 4
    mov rbx, 1
    add rcx, 60
    mov rdx, 8
    int 80h
    ret

section '.print_number' executable
; | input:
; rax = number
print_number:
    push rax
    push rbx
    push rcx
    push rdx
    xor rcx, rcx
    .next_iter:
        mov rbx, 10
        xor rdx, rdx
        div rbx
        add rdx, '0'
        push rdx
        inc rcx
        cmp rax, 0
        je .print_iter
        jmp .next_iter
    .print_iter:
        cmp rcx, 0
        je .close
        pop rax
        call print_char
        dec rcx
        jmp .print_iter
    .close:
        pop rdx
        pop rcx
        pop rbx
        pop rax
        ret
section '.print_char' executable
; | input
; rax = char
print_char:
    push rdx
    push rcx
    push rbx
    push rax

    mov [_bss_char], al

    mov rax, 4
    mov rbx, 1
    mov rcx, _bss_char
    mov rdx, 1
    int 0x80

    pop rax
    pop rbx
    pop rcx
    pop rdx
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