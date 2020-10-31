extrn scanf
extrn printf
macro print format*, arg1, arg2, arg3 {
  mov rdi, format
  if arg1 eq
    xor rsi, rsi
  else
    mov rsi, arg1
  end if
  if arg2 eq
    xor rdx, rdx
  else
    mov rdx, arg2
  end if
  if arg3 eq
    xor rcx, rcx
  else
    mov rcx, arg3
  end if
  xor rax, rax
  call printf
}

macro read format*, arg1*, arg2, arg3, arg4 {
  push rbp
  lea rdi, [format]
  mov rsi, arg1
  if arg2 eq
    xor rdx, rdx
  else
    mov rdx, arg2
  end if
  if arg3 eq
    xor rcx, rcx
  else
    mov rcx, arg3
  end if
  if arg4 eq
    xor r8, r8
  else
    mov r8, arg4
  end if
  xor rax, rax
  call scanf
  pop rbp
}