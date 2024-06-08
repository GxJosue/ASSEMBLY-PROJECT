section .data
    menu db "Seleccione una opción:", 0xA
         db "1. Calcular el área de un triángulo", 0xA
         db "2. Calcular el área de un rectángulo", 0xA
         db "Opción: ", 0
    len_menu equ $-menu

    triangle_base_msg db "Ingrese la base del triángulo: ", 0
    len_triangle_base_msg equ $-triangle_base_msg

    triangle_height_msg db "Ingrese la altura del triángulo: ", 0
    len_triangle_height_msg equ $-triangle_height_msg

    rectangle_length_msg db "Ingrese la longitud del rectángulo: ", 0
    len_rectangle_length_msg equ $-rectangle_length_msg

    rectangle_width_msg db "Ingrese el ancho del rectángulo: ", 0
    len_rectangle_width_msg equ $-rectangle_width_msg

    result_msg db "El área es: ", 0
    len_result_msg equ $-result_msg

    newline db 0xA, 0

section .bss
    option resb 1
    input resb 4
    base resd 1
    height resd 1
    length resd 1
    width resd 1
    area resd 1
    num_buffer resb 12 

section .text
    global _start

_start:
    mov edx, len_menu
    mov ecx, menu
    mov ebx, 1
    mov eax, 4
    int 0x80

    mov edx, 2
    mov ecx, option
    mov ebx, 0
    mov eax, 3
    int 0x80

    mov al, [option]
    cmp al, '1'
    je triangle_area
    cmp al, '2'
    je rectangle_area
    jmp exit

triangle_area:
    mov edx, len_triangle_base_msg
    mov ecx, triangle_base_msg
    mov ebx, 1
    mov eax, 4
    int 0x80

    call read_input
    mov [base], eax

    mov edx, len_triangle_height_msg
    mov ecx, triangle_height_msg
    mov ebx, 1
    mov eax, 4
    int 0x80

    call read_input
    mov [height], eax

    mov eax, [base]
    imul eax, [height]
    imul eax, 100
    mov ebx, 2
    div ebx
    mov [area], eax

    jmp display_result

rectangle_area:

    mov edx, len_rectangle_length_msg
    mov ecx, rectangle_length_msg
    mov ebx, 1
    mov eax, 4
    int 0x80

    call read_input
    mov [length], eax

    mov edx, len_rectangle_width_msg
    mov ecx, rectangle_width_msg
    mov ebx, 1
    mov eax, 4
    int 0x80

    call read_input
    mov [width], eax

    mov eax, [length]
    imul eax, [width]
    imul eax, 100
    mov [area], eax

display_result:

    mov edx, len_result_msg
    mov ecx, result_msg
    mov ebx, 1
    mov eax, 4
    int 0x80

    mov eax, [area]
    call print_num_with_decimals

    mov edx, 1
    mov ecx, newline
    mov ebx, 1
    mov eax, 4
    int 0x80

exit:

    mov eax, 1
    xor ebx, ebx
    int 0x80

read_input:

    mov edx, 4
    mov ecx, input
    mov ebx, 0
    mov eax, 3
    int 0x80


    mov eax, 0
    mov ecx, input
    mov edx, 0
convert_loop:
    mov bl, [ecx]
    cmp bl, 0xA
    je convert_end
    sub bl, '0'
    imul eax, eax, 10
    add eax, ebx
    inc ecx
    jmp convert_loop
convert_end:
    ret

print_num_with_decimals:

    mov ebx, 100
    xor edx, edx
    div ebx  ; EAX = parte entera, EDX = parte decimal

    push edx

    mov ecx, 10
    xor edx, edx
    mov edi, num_buffer + 11
    mov byte [edi], 0

print_num_loop:
    xor edx, edx
    div ecx
    add dl, '0'
    dec edi
    mov [edi], dl
    test eax, eax
    jnz print_num_loop

    mov edx, num_buffer + 11
    sub edx, edi
    mov ecx, edi
    mov ebx, 1
    mov eax, 4
    int 0x80

    mov edx, 1
    mov ecx, '.'
    mov [input], cl
    mov ecx, input
    mov ebx, 1
    mov eax, 4
    int 0x80

    pop eax
    mov ecx, 10
    xor edx, edx
    mov edi, num_buffer + 11
    mov byte [edi], 0

    mov dx, ax
    cmp dx, 10
    jb single_digit_decimal
    jmp print_decimal_loop

single_digit_decimal:
    mov byte [edi-1], '0'
    dec edi

print_decimal_loop:
    xor edx, edx
    div ecx
    add dl, '0'
    dec edi
    mov [edi], dl
    test eax, eax
    jnz print_decimal_loop

    mov edx, num_buffer + 11
    sub edx, edi
    mov ecx, edi
    mov ebx, 1
    mov eax, 4
    int 0x80
    ret
