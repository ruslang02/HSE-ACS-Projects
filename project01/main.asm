format ELF64
public main
extrn scanf
extrn printf

section '.text' writable
  main:
    mov rdi, DESCRIPTION
    xor rsi, rsi
    xor rax, rax
    call printf
    finit
  input_lines:
    mov [i], 0
    .next:
      inc [i]

      mov rdi, LINE_INPUT
      mov rsi, rcx
      mov rdx, rcx
      xor rax, rax
      call printf

      push rbp
      lea rdi, [LINE_INPUT_FORMAT]
      mov rsi, xLine1
      mov rdx, yLine1
      mov rcx, xLine2
      mov r8, yLine2
      xor rax, rax
      call scanf
      pop rbp

      fld qword [xLine1]
      fsub qword [xLine2]
      

      fld qword [yLine1]
      fsub qword [yLine2]
      fdivrp
      mov rdx, LINES
      fst qword [rdx+rcx]




      mov rcx, [i]
      cmp rcx, [N]
      jne .next
      jmp process_lines
  
  process_lines:
    xor rcx, rcx
    .next_line:
      mov rdx, rcx
      inc rdx
        ret
      .find_parallel_line:
        mov rbx, LINES
        fld qword [rbx + rcx]
        fcom qword [rbx + rdx]
        fstsw ax
        sahf
        jne .check_loop
      .output_line:
        push rcx
        push rdx
        mov rdi, LINE_OUTPUT
        mov rsi, rcx
;       mov rdx, rdx
        xor rax, rax
        call printf
        pop rdx
        pop rcx
      .check_loop:
        inc rdx
        cmp rdx, [N]
        jne .find_parallel_line
      .inc_counter:
        inc rcx
        cmp rcx, [N]
        jne .next_line
        jmp exit
  exit:
    mov rax, 1
    int 80h
    ret
 
section '.data' writable
  DESCRIPTION db "Ruslan Garifullin (https://github.com/ruslang02)", 10, "From a set of line segments (set by the coords of two points) find parallel ones.", 10, 10, 0
  ; M dq 4294967296
  ; M_N dq -4294967295
  N dq 5
  LINES rq 5; double[5]
  LINE_INPUT db "Line %d: ", 0
  LINE_INPUT_FORMAT db "%f %f %f %f", 0
  LINE_OUTPUT db "Line #%d is parallel to line #%d.", 10, 0
  xLine1 dq ?
  yLine1 dq ?
  xLine2 dq ?
  yLine2 dq ?
  i dq 0