section .data
    menu_msg db 'Seleccione una figura:', 0xA, '1. Triangulo', 0xA, '2. Rectangulo', 0xA, 0
    msg_len equ $ - menu_msg
    invalid_msg db 'Opcion invalida.', 0xA, 0
    prompt db 'Ingrese su opcion:  ', 0

    base_prompt db 'Ingrese la base: ', 0
    base_prompt_len equ $ - base_prompt
    height_prompt db 'Ingrese la altura: ', 0
    height_prompt_len equ $ - height_prompt
    result_msg db 'El area es: ', 0
    result_msg_len equ $ - result_msg
    newline db 0xA
    newline_len equ $ - newline
    ; Define el carácter de punto decimal
    dot db '.', 0

    section .bss
    option resb 10       ; buffer para almacenar la opción del usuario
    base resb 11
    height resb 11
    base_val resd 1
    height_val resd 1
    area resd 1

section .text
    global _start

    ; print_string: Imprime una cadena de caracteres en la salida estándar
    ; Entrada:
    ;   ecx: Dirección de la cadena a imprimir
    print_string:
        push edx            ; Guardar edx
    .loop:
        movzx eax, byte [ecx]   ; Cargar el siguiente carácter de la cadena
        test al, al         ; Verificar si es el final de la cadena
        jz .done            ; Si es así, terminar
        mov [esp], eax      ; Colocar el carácter en el primer byte de la pila
        mov eax, 4          ; Llamar a sys_write
        mov ebx, 1          ; File descriptor stdout
        mov ecx, esp        ; Dirección del carácter a imprimir
        mov edx, 1          ; Longitud de un byte
        int 0x80            ; Llamar al kernel
        inc ecx             ; Mover al siguiente carácter
        jmp .loop           ; Repetir el proceso
    .done:
        pop edx             ; Restaurar edx
        ret

    ; atoi: Convierte una cadena ASCII a un número entero
; Entrada:
;   ebx: Puntero a la cadena ASCII
; Salida:
;   eax: Valor entero convertido
atoi:
    xor eax, eax         ; Inicializar el valor entero a 0
.loop:
    movzx edx, byte [ebx]   ; Cargar el siguiente carácter de la cadena
    test dl, dl         ; Verificar si es el final de la cadena
    jz .done            ; Si es así, terminar
    sub edx, '0'        ; Convertir de carácter ASCII a dígito numérico
    imul eax, 10        ; Multiplicar el valor actual por 10
    add eax, edx        ; Sumar el nuevo dígito al valor actual
    inc ebx             ; Mover al siguiente carácter
    jmp .loop           ; Repetir el proceso
.done:
    ret

; print_int: Imprime un número entero en la salida estándar
; Entrada:
;   ecx: El número entero a imprimir
print_int:
    push ebx            ; Guardar ebx
    push ecx            ; Guardar ecx
    mov ebx, 10         ; Base decimal
    xor edx, edx        ; Inicializar edx a 0 (para división)
.loop:
    div ebx             ; Dividir ecx por 10, resultado en eax, residuo en edx
    add dl, '0'         ; Convertir el dígito a ASCII
    push dx             ; Empujar el dígito en la pila
    test eax, eax       ; Verificar si hemos terminado
    jz .print           ; Si es así, terminar
    jmp .loop           ; Repetir el proceso
.print:
    pop eax             ; Sacar el dígito de la pila
    mov [esp], al       ; Colocar el dígito en el primer byte de la pila
    mov eax, 4          ; Llamar a sys_write
    mov ebx, 1          ; File descriptor stdout
    mov ecx, esp        ; Dirección del dígito a imprimir
    mov edx, 1          ; Longitud de un byte
    int 0x80            ; Llamar al kernel
    pop ecx             ; Restaurar ecx
    pop ebx             ; Restaurar ebx
    ret

    ; print_float: Imprime un número flotante en la salida estándar
    ; Entrada:
    ;   eax: El número flotante a imprimir
    ;   ecx: El número de decimales de precisión
    ; print_float: Imprime un número flotante en la salida estándar
    ; Entrada:
    ;   eax: El número flotante a imprimir
    ;   ecx: El número de decimales de precisión
    print_float:
    push eax            ; Guardar eax
    push ecx            ; Guardar ecx

    mov edx, eax        ; Copiar el número flotante a edx

    ; Verificar el signo del número flotante
    test edx, edx      ; Comprobar el bit de signo
    jns .positive       ; Si es positivo, continuar
    push edx           ; Guardar el signo negativo en la pila
    mov eax, '-'       ; Imprimir el signo negativo
    mov [esp], eax
    call print_string  ; Llamar a la función print_string para imprimir el signo
    pop edx            ; Recuperar el signo negativo de la pila
    neg edx            ; Cambiar el signo del número flotante
    .positive:

    ; Imprimir la parte entera
    call print_int      ; Llamar a la función print_int para imprimir la parte entera

    ; Imprimir el punto decimal
    mov eax, 4
    mov ebx, 1
    mov ecx, dot
    mov edx, 1
    int 0x80

    ; Calcular la parte decimal
    mov eax, 10
    xor ecx, ecx       ; Limpiar ecx para la división
    div eax            ; Dividir el número flotante por 10 para obtener la parte decimal
    mov ecx, edx       ; Mover el residuo a ecx (necesario para la parte decimal)

    ; Imprimir la parte decimal
    call print_int     ; Llamar a la función print_int para imprimir la parte decimal

    ; Restaurar los registros
    pop ecx             ; Restaurar ecx
    pop eax             ; Restaurar eax
    ret

_start:
    ; Mostrar el menú
    mov eax, 4          ; syscall para sys_write
    mov ebx, 1          ; file descriptor stdout
    mov ecx, menu_msg   ; mensaje a imprimir
    mov edx, msg_len    ; longitud del mensaje
    int 0x80            ; llamar al kernel

    ; Pedir la opción al usuario
    mov eax, 4          ; syscall para sys_write
    mov ebx, 1          ; file descriptor stdout
    mov ecx, prompt     ; mensaje a imprimir
    mov edx, 17         ; longitud del mensaje
    int 0x80            ; llamar al kernel

    ; Leer la opción ingresada por el usuario
    mov eax, 3          ; syscall para sys_read
    mov ebx, 0          ; file descriptor stdin
    mov ecx, option     ; buffer para almacenar la opción
    mov edx, 2          ; longitud máxima de entrada
    int 0x80            ; llamar al kernel

    ; Eliminar el carácter de nueva línea si está presente
    mov eax, dword [esp + 8]  ; Obtener la longitud de la entrada del usuario
    sub eax, 1          ; Restar 1 para verificar el último carácter
    movzx edx, byte [option + eax]  ; Obtener el último carácter
    cmp dl, 0xA         ; Comprobar si es un carácter de nueva línea
    je .remove_newline  ; Saltar si es un carácter de nueva línea
    jmp .conversion_done  ; Saltar si no hay un carácter de nueva línea
.remove_newline:
    mov byte [option + eax], 0  ; Reemplazar el carácter de nueva línea con NULL

.conversion_done:
    ; Convertir la opción a un número
    mov al, [option]
    sub al, '0'

    ; Verificar la opción ingresada
    cmp al, 1
    je option_triangle
    cmp al, 2
    je option_rectangle

    ; Opción inválida
    mov eax, 4          ; syscall para sys_write
    mov ebx, 1          ; file descriptor stdout
    mov ecx, invalid_msg; mensaje a imprimir
    mov edx, 18         ; longitud del mensaje
    int 0x80            ; llamar al kernel

    ; Salir del programa
    mov eax, 1          ; syscall para sys_exit
    xor ebx, ebx        ; código de salida 0
    int 0x80            ; llamar al kernel

option_triangle:
    ; Solicitar la base del triángulo
    mov eax, 4
    mov ebx, 1
    mov ecx, base_prompt
    mov edx, base_prompt_len
    int 0x80

    ; Leer la base ingresada por el usuario
    mov eax, 3
    mov ebx, 0
    mov ecx, base
    mov edx, 10
    int 0x80

    ; Convertir la base a un número
    mov ebx, base
    call atoi
    mov [base_val], eax

    ; Solicitar la altura del triángulo
    mov eax, 4
    mov ebx, 1
    mov ecx, height_prompt
    mov edx, height_prompt_len
    int 0x80

    ; Leer la altura ingresada por el usuario
    mov eax, 3
    mov ebx, 0
    mov ecx, height
    mov edx, 10
    int 0x80

    ; Convertir la altura a un número
    mov ebx, height
    call atoi
    mov [height_val], eax

    ; Calcular el área del triángulo
    mov eax, [base_val]
    imul eax, [height_val]
    sar eax, 1  ; Dividir por 2 para calcular el área de un triángulo
    mov [area], eax  ; Guardar el área en [area]


    ; Mostrar el resultado
    mov eax, 4
    mov ebx, 1
    mov ecx, result_msg
    mov edx, result_msg_len
    int 0x80

    ; Mostrar el área calculada
    ; Comprobar si el área es un número entero o un número con decimales
    mov eax, [area]
    mov edx, 0          ; Limpiar edx
    test eax, 0xFFFFF000  ; Comprobar si el área tiene decimales
    jz .print_int       ; Si el área no tiene decimales, imprimir como número entero
    ; Si el área tiene decimales, convertir y mostrar el área como un número flotante
    mov eax, [area]
    mov ecx, 2          ; 2 decimales de precisión
    call print_float    ; Llamar a la función print_float para imprimir el área
    jmp .after_print    ; Saltar a la sección después de imprimir el área

.print_int:
    mov eax, [area]
    call print_int

.after_print:
    ; Agregar un salto de línea después de imprimir el área
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, newline_len
    int 0x80

    jmp exit_program


option_rectangle:
    ; Solicitar la base del rectángulo
    mov eax, 4
    mov ebx, 1
    mov ecx, base_prompt
    mov edx, base_prompt_len
    int 0x80

    ; Leer la base ingresada por el usuario
    mov eax, 3
    mov ebx, 0
    mov ecx, base
    mov edx, 10
    int 0x80

    ; Convertir la base a un número
    mov ebx, base
    call atoi
    mov [base_val], eax

    ; Solicitar la altura del rectángulo
    mov eax, 4
    mov ebx, 1
    mov ecx, height_prompt
    mov edx, height_prompt_len
    int 0x80

    ; Leer la altura ingresada por el usuario
    mov eax, 3
    mov ebx, 0
    mov ecx, height
    mov edx, 10
    int 0x80

    ; Convertir la altura a un número
    mov ebx, height
    call atoi
    mov [height_val], eax

    ; Calcular el área del rectángulo
    mov eax, [base_val]
    imul eax, [height_val]
    mov [area], eax  ; Guardar el área en [area]

    ; Mostrar el resultado
    mov eax, 4
    mov ebx, 1
    mov ecx, result_msg
    mov edx, result_msg_len
    int 0x80

    ; Mostrar el área calculada
    ; Comprobar si el área es un número entero o un número con decimales
    mov eax, [area]
    mov edx, 0          ; Limpiar edx
    test eax, 0xFFFFF000  ; Comprobar si el área tiene decimales
    jz .print_int       ; Si el área no tiene decimales, imprimir como número entero
    ; Si el área tiene decimales, convertir y mostrar el área como un número flotante
    mov eax, [area]
    mov ecx, 2          ; 2 decimales de precisión
    call print_float    ; Llamar a la función print_float para imprimir el área
    jmp .after_print    ; Saltar a la sección después de imprimir el área

    .print_int:
    mov eax, [area]
    call print_int

    .after_print:
    ; Agregar un salto de línea después de imprimir el área
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, newline_len
    int 0x80

    jmp exit_program

exit_program:
    ; Salir del programa
    mov eax, 1          ; syscall para sys_exit
    xor ebx, ebx        ; código de salida 0
    int 0x80            ; llamar al kernel