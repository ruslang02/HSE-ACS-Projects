format ELF64
public _start

section '.data' writeable
  _data:
    WELCOME_MSG db "Welcome to the Counter app!", 10, 0
    NEW_ITEM_MSG db "Enter new item's price: ", 0
    STATUS_MSG db "Number of items: 0", 0
    TOTAL_MSG db "It's time to pay! Total price: ", 0
    
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

    call exit
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