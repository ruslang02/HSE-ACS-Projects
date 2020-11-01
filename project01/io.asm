extrn scanf
extrn printf

; printf macro
macro print format*, arg1, arg2, arg3 {
  push rax
  push rdx
  push rcx
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
  pop rcx
  pop rdx
  pop rax
}

; scanf macro
macro read format*, arg1*, arg2*, arg3*, arg4* {
  push rcx
  push rdx
  lea rdi, [format]
  mov rsi, arg1
  mov rdx, arg2
  mov rcx, arg3
  mov r8, arg4
  xor rax, rax
  call scanf
  pop rdx
  pop rcx
}