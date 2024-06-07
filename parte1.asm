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

section .text
    global _start

_start:
    ; Mostrar menú
    mov edx, len_menu
    mov ecx, menu
    mov ebx, 1
    mov eax, 4
    int 0x80

    ; Leer opción
    mov edx, 2
    mov ecx, option
    mov ebx, 0
    mov eax, 3
    int 0x80

    ; Comparar opción
    mov al, [option]
    cmp al, '1'
    je triangle_area
    cmp al, '2'
    je rectangle_area
    jmp exit

triangle_area:
    ; Pedir base del triángulo
    mov edx, len_triangle_base_msg
    mov ecx, triangle_base_msg
    mov ebx, 1
    mov eax, 4
    int 0x80

    ; Leer base del triángulo
    call read_input
    mov [base], eax

    ; Pedir altura del triángulo
    mov edx, len_triangle_height_msg
    mov ecx, triangle_height_msg
    mov ebx, 1
    mov eax, 4
    int 0x80

    ; Leer altura del triángulo
    call read_input
    mov [height], eax

    ; Calcular área: (base * altura) / 2
    mov eax, [base]
    imul eax, [height]
    shr eax, 1
    mov [area], eax

    jmp display_result

rectangle_area:
    ; Pedir longitud del rectángulo
    mov edx, len_rectangle_length_msg
    mov ecx, rectangle_length_msg
    mov ebx, 1
    mov eax, 4
    int 0x80

    ; Leer longitud del rectángulo
    call read_input
    mov [length], eax

    ; Pedir ancho del rectángulo
    mov edx, len_rectangle_width_msg
    mov ecx, rectangle_width_msg
    mov ebx, 1
    mov eax, 4
    int 0x80

    ; Leer ancho del rectángulo
    call read_input
    mov [width], eax

    ; Calcular área: longitud * ancho
    mov eax, [length]
    imul eax, [width]
    mov [area], eax

display_result:
    ; Mostrar mensaje del resultado
    mov edx, len_result_msg
    mov ecx, result_msg
    mov ebx, 1
    mov eax, 4
    int 0x80

    ; Mostrar área
    mov eax, [area]
    call print_num

    ; Agregar nueva línea
    mov edx, 1
    mov ecx, newline
    mov ebx, 1
    mov eax, 4
    int 0x80

exit:
    ; Salir del programa
    mov eax, 1
    xor ebx, ebx
    int 0x80

read_input:
    ; Leer un número del input
    mov edx, 4
    mov ecx, input
    mov ebx, 0
    mov eax, 3
    int 0x80

    ; Convertir string a número
    mov eax, 0
    mov ecx, input
    mov edx, 0
convert_loop:
    mov bl, [ecx]
    cmp bl, 0xA
    je convert_end
    sub bl, '0'
    imul eax, 10
    add eax, ebx
    inc ecx
    jmp convert_loop
convert_end:
    ret

print_num:
    ; Imprimir un número
    mov ecx, 10
    xor edx, edx

print_num_loop:
    xor edx, edx
    div ecx
    add dl, '0'
    push dx
    test eax, eax
    jnz print_num_loop

print_num_output:
    pop dx
    mov [input], dl
    mov edx, 1
    mov ecx, input
    mov ebx, 1
    mov eax, 4
    int 0x80
    cmp esp, input
    jnz print_num_output
    ret

    ;funciona todo good, solo da unos caracteres de más en la respuesta