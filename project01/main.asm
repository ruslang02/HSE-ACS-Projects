format ELF64
public main
N EQU 5; Number of lines to compare.
WORD_SIZE EQU 4; dd size
include 'io.asm'; I/O macros
section '.text' writable
  main:
    print DESCRIPTION, N
    call input_lines
    call process_lines

    mov rax, 1
    int 80h
  input_lines:
    mov rbx, LINES
    mov rcx, N
    .next:
      mov rdx, N
      sub rdx, rcx
      print LINE_INPUT, rdx; input lines data
      ; using scanf resets all registers
      read LINE_INPUT_FORMAT, x1, y1, x2, y2
      call count_tg
      cmp al, byte 1; NaN check
      jne .continue
      .error:
        call print_error
        jmp .next
      .continue:
        fstp dword [rbx + rdx * WORD_SIZE]; load angle tan into array
        loop .next
    ret
  print_error:
    print POINT_PROVIDED_ERROR
    ret
  ; output: ax - status flags
  count_tg:
    finit; reset FPU state
    ; <tg A = (y2 - y1) / (x2 - x1)>
    fld dword [x2]
    fsub dword [x1]
    fld dword [y2]
    fsub dword [y1]
    fdivrp; reverse divide
    ; </tg A>
    fstsw ax; load status flags into AX
    ret
  process_lines:
    ; process lines, find parallel
    mov rbx, LINES; save array pointer into register, otherwise does not compile
    mov rcx, N
    dec rcx
    .next_line:
    mov rdx, rcx
    .find_parallel_line:
      ; tg A = tg B => lines are parallel
      ; i tried to do comparison by eplison but the values
      ; can not load into the FPU (endianess) so i left it like this
      ;
      ; fld dword [rbx + (rcx + (-1)) * WORD_SIZE]
      ; fsub dword [rbx + rdx * WORD_SIZE]
      ; fcomp dword [EPSILON]
      mov eax, [rbx + (rcx + (-1)) * WORD_SIZE]
      cmp eax, [rbx + rdx * WORD_SIZE]
      je .print
      jmp .continue
    .print:
      dec rcx
      print LINE_OUTPUT, rdx, rcx
      inc rcx
    .continue:
      loop .find_parallel_line
    mov rcx, rdx
    loop .next_line
    ret
section '.data' writable
  DESCRIPTION db\
    "Ruslan Garifullin (https://github.com/ruslang02)", 10,\ 
    "From N=%d lines (set by the coords of two points) find parallel ones.", 10,\ 
    "Input format: <x1> <y1> <x2> <y2>.", 10,\ 
    10, 0
  POINT_PROVIDED_ERROR db "You have given a point. Line expected.", 10, 0
  LINES rd N; float[N]
  LINE_INPUT db "Line %d: ", 0
  LINE_INPUT_FORMAT db "%f %f %f %f", 0
  LINE_OUTPUT db "Line #%d is parallel to line #%d.", 10, 0
  x1 dd ?
  y1 dd ?
  x2 dd ?
  y2 dd ?