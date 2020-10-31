format ELF64
public main
N EQU 5; Number of lines to compare.
WORD_SIZE EQU 4; dd size
include 'io.asm'
section '.text' writable
  main:
    finit
    print DESCRIPTION, N
  input_lines:
    mov [temp], 0
    .next:
      print LINE_INPUT, [temp]
      
      read LINE_INPUT_FORMAT, xLine1, yLine1, xLine2, yLine2
      ; <tg A = (y2 - y1) / (x2 - x1)>
      fld dword [xLine2]
      fsub dword [xLine1]
      fld dword [yLine2]
      fsub dword [yLine1]
      fdivrp
      ; </tg A>
      mov rdx, LINES
      fst dword [temp2]; put float number into array
      mov eax, [temp2]
      cmp eax, [NaN]
      jne .inc
      print POINT_PROVIDED_ERROR
      jmp .next
      .inc:
        mov rcx, [temp]
        mov [rdx + rcx * WORD_SIZE], eax
        inc [temp]
        mov rcx, [temp]
        cmp rcx, N
        jne .next  
  process_lines:
    mov rbx, LINES
    xor rcx, rcx
    .next_line:
      mov rdx, rcx
      inc rdx
      .find_parallel_line:
        ; tg A = tg B => lines are parallel
        mov eax, [rbx + rcx * WORD_SIZE]
        cmp eax, [rbx + rdx * WORD_SIZE]
        jne .check_loop
      .output_line:
        push rcx
        push rdx
        print LINE_OUTPUT, rcx, rdx
        pop rdx
        pop rcx
      .check_loop:
        inc rdx
        cmp rdx, N
        jne .find_parallel_line
      .inc_counter:
        inc rcx
        cmp rcx, N - 1
        jne .next_line
  exit:
    mov rax, 1
    int 80h
    ret

section '.data' writable
  DESCRIPTION db\
    "Ruslan Garifullin (https://github.com/ruslang02)", 10,\ 
    "From N=%d lines (set by the coords of two points) find parallel ones.", 10,\ 
    "Input format: <x1> <y1> <x2> <y2>. Supports floating-point numbers, separated by '.'", 10,\ 
    10, 0
  POINT_PROVIDED_ERROR db "You have given a point. Line expected.", 10, 0
  LINES rd N; float[N]
  LINE_INPUT db "Line %d: ", 0
  LINE_INPUT_FORMAT db "%f %f %f %f", 0
  LINE_OUTPUT db "Line #%d is parallel to line #%d.", 10, 0
  xLine1 dd ?
  yLine1 dd ?
  xLine2 dd ?
  yLine2 dd ?
  temp dq 0
  temp2 dd 0
  NaN dd 0xffc00000
