section .data
    menu db '----------------------------------', 10
         db 'MENU', 10
         db '[A]dd', 10
         db '[S]ubtract', 10
         db '[M]ultiply', 10
         db '[D]ivide', 10
         db '----------------------------------', 10
         db 'Enter your choice: '
    menu_len equ $ - menu

    first db 'Enter first number: '
    first_len equ $ - first

    second db 'Enter second number: '
    second_len equ $ - second

    sum db 'The sum is '
    sum_len equ $ - sum

    difference db 'The difference is '
    difference_len equ $ - difference

    product db 'The product is '
    product_len equ $ - product

    quotient db 'The quotient is '
    quotient_len equ $ - quotient

    again db 10, 'Do you want to try again (Y/N): '
    again_len equ $ - again

    error db 'Cannot divide by zero.', 10
    error_len equ $ - error

    clear db 27, '[2J', 27, '[H'
    clear_len equ $ - clear

    digit db '0'

section .bss
    input resb 4
    choice resb 1
    num1 resd 1
    num2 resd 1

section .text
    global _start

; display
print_text:
    mov eax, 4
    mov ebx, 1
    int 0x80
    ret

print_digit:
    add al, '0'
    mov [digit], al

    mov eax, 4
    mov ebx, 1
    mov ecx, digit
    mov edx, 1
    int 0x80
    ret

print_number:
    mov ebx, 10
    xor esi, esi

get_digit:
    xor edx, edx
    div ebx

    push edx
    inc esi

    cmp eax, 0
    jne get_digit

show_digit:
    pop eax
    call print_digit

    dec esi
    jnz show_digit
    ret

read_input:
    mov eax, 3
    mov ebx, 0
    mov ecx, input
    mov edx, 4
    int 0x80
    ret

read_number:
    call read_input

    movzx eax, byte [input]
    sub eax, '0'

    cmp byte [input + 1], 10
    je number_done

    imul eax, eax, 10

    movzx edx, byte [input + 1]
    sub edx, '0'
    add eax, edx

number_done:
    ret

clear_screen:
    mov ecx, clear
    mov edx, clear_len
    call print_text
    ret

; addition
addition:
    mov ecx, sum
    mov edx, sum_len
    call print_text

    mov eax, [num1]
    add eax, [num2]
    call print_number
    ret

; subtraction
subtraction:
    mov ecx, difference
    mov edx, difference_len
    call print_text

    mov eax, [num1]
    sub eax, [num2]
    call print_number
    ret

; multiplication
multiplication:
    mov ecx, product
    mov edx, product_len
    call print_text

    mov eax, [num1]
    mov ebx, [num2]
    mul ebx
    call print_number
    ret

; division
division:
    cmp dword [num2], 0
    je divide_zero

    mov ecx, quotient
    mov edx, quotient_len
    call print_text

    mov eax, [num1]
    xor edx, edx
    mov ebx, [num2]
    div ebx
    call print_number
    ret

divide_zero:
    mov ecx, error
    mov edx, error_len
    call print_text
    ret

_start:
menu_loop:
    call clear_screen

    mov ecx, menu
    mov edx, menu_len
    call print_text
    call read_input

    mov al, [input]
    and al, 0DFh            ; for small letters to capital letters
    mov [choice], al

    cmp al, 'A'
    je enter_numbers
    cmp al, 'S'
    je enter_numbers
    cmp al, 'M'
    je enter_numbers
    cmp al, 'D'
    je enter_numbers
    jmp menu_loop

enter_numbers:
    mov ecx, first
    mov edx, first_len
    call print_text
    call read_number
    mov [num1], eax

    mov ecx, second
    mov edx, second_len
    call print_text
    call read_number
    mov [num2], eax

    cmp byte [choice], 'A'
    je add_choice
    cmp byte [choice], 'S'
    je subtract_choice
    cmp byte [choice], 'M'
    je multiply_choice

    call division
    jmp try_again

add_choice:
    call addition
    jmp try_again

subtract_choice:
    call subtraction
    jmp try_again

multiply_choice:
    call multiplication

try_again:
    mov ecx, again
    mov edx, again_len
    call print_text
    call read_input

    mov al, [input]
    and al, 0DFh

    cmp al, 'Y'
    je menu_loop

    ; exit
    mov eax, 1
    xor ebx, ebx
    int 0x80