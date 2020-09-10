format ELF64
public _start
section '.data' writeable
   userMsg db 'Please enter a number: ', 0 ;Ask the user to enter a number
   lenUserMsg = $-userMsg             ;The length of the message
   dispMsg db 'You have entered: ', 0
   lenDispMsg = $-dispMsg                 

section '.bss' writable           ;Uninitialized data
   num db ?

section '.text' executable	
  _start:                ;User prompt
    mov eax, 4
    mov ebx, 1
    mov ecx, userMsg
    mov edx, lenUserMsg
    int 80h

    ;Read and store the user input
    mov eax, 3
    mov ebx, 2
    mov ecx, num  
    mov edx, 5          ;5 bytes (numeric, 1 for sign) of that information
    int 80h
	
    ;Output the message 'The entered number is: '
    mov eax, 4
    mov ebx, 1
    mov ecx, dispMsg
    mov edx, lenDispMsg
    int 80h  

    ;Output the number entered
    mov eax, 4
    mov ebx, 1
    mov ecx, num
    mov edx, 5
    int 80h  
    
    ;Exit code
    mov eax, 1
    mov ebx, 0
    int 80h