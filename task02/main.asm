format ELF64
public _start
section '.data' writable
  DESCRIPTION db "Ruslan Garifullin (https://github.com/ruslang02)", 10, "From array A[N] create an array B[N] from odd elements.", 10, 10, 0
  ARRAY_A db "Array A:", 10, 0
  ARRAY_B db "Array B:", 10, 0
  ENTER_N db "Enter N: ", 0
  NUM_ERROR db "Number is either too small or too big.", 10, 0
  INPUT_BEFORE db "[", 0
  INPUT_AFTER db "] = ", 0
  EMPTY_MSG db "(empty)", 10, 0
  NEW_LINE db 10, 0
  MINUS dq "-"
  N dq ?
  R dq 0
  MAX dq 100
  M dq 4294967296
  M_N dq -4294967295
  ARRAY rq 100
  OUTPUT_ARRAY rq 100
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

    input_n:
      mov rax, ENTER_N
      call str_print

      call input_number
      cmp rax, 0
      jle .error
      cmp rax, [MAX]
      jge .error
      mov [N], rax
      jmp .array_process
    .error:
      mov rax, NUM_ERROR
      call str_print
      jmp input_n
    .array_process:
      call read_array

      mov rax, ARRAY_A
      call str_print
      mov rax, ARRAY
      mov rbx, [N]
      call print_array

      call process_array

      mov rax, ARRAY_B
      call str_print
      mov rax, OUTPUT_ARRAY
      mov rbx, [R]
      call print_array

      call exit
      ret
  exit:
    mov rax, 1
    mov rbx, 0
    int 80h

section '.read_array' executable
  ; | input
  ; N - number of elements to read
  read_array:
    push rax
    push rcx
    xor rcx, rcx; counter
    .next_item:
      mov rax, INPUT_BEFORE
      call str_print
      mov rax, rcx
      call print_number
      mov rax, INPUT_AFTER
      call str_print; [i] = ...

      call input_number
      cmp rax, [M]
      jge .error
      cmp rax, [M_N]
      jle .error
      mov [ARRAY + rcx * 8], rax
      inc rcx; rcx++
      cmp rcx, [N]; if (rcx == N) return;
      jnz .next_item
      jmp .exit
    .error:
      mov rax, NUM_ERROR
      call str_print
      jmp .next_item
    .exit:
      pop rcx
      pop rax
      ret
section '.print_array' executable
  ; | input:
  ; rax = pointer to array
  ; rbx = array length
  print_array:
    push rax
    push rbx
    push rcx
    push r8
    push r9
    mov r8, rax
    mov r9, rbx
    xor rcx, rcx; counter
    .next_item:
      cmp rcx, r9; if (rcx == N) return;
      jge .return

      mov rax, INPUT_BEFORE
      call str_print
      mov rax, rcx
      call print_number
      mov rax, INPUT_AFTER
      call str_print; [i] = ...

      mov rax, [r8 + rcx * 8]
      call print_number
      mov rax, NEW_LINE
      call str_print

      inc rcx; rcx++
      jmp .next_item
    .return:
      cmp rcx, 0
      je .empty_msg
    .clear:
      pop r9
      pop r8
      pop rcx
      pop rbx
      pop rax
      ret
    .empty_msg:
      mov rax, EMPTY_MSG
      call str_print
      jmp .clear

section '.process_array' executable
  process_array:
    push rax
    push rbx
    push rcx
    push rdx
    push r8
    push r9
    mov rcx, 0; counter
    xor r8, r8; counter for output array
    .next_item:
      cmp rcx, [N]
      jge .return
      mov rax, [ARRAY + rcx * 8]
      mov r9, rax
      mov rbx, 2
      div rbx
      inc rcx
      cmp rdx, 0
      je .next_item
    .push_array:
      mov [OUTPUT_ARRAY + r8 * 8], r9
      inc r8
      jmp .next_item
    .return:
      mov [R], r8
      pop r9
      pop r8
      pop rdx
      pop rcx
      pop rbx
      pop rax
      ret
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

section '.print_number' executable
; | input:
; rax = number
print_number:
    push rax
    push rbx
    push rcx
    push rdx
    xor rcx, rcx
    cmp rax, 0
    jl .toggle_invert
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
    .toggle_invert:
        push rax
        mov rax, 45
        call print_char
        pop rax
        push rbx
        mov rbx, -1
        imul rbx
        pop rbx
        jmp .next_iter
    .close:
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
