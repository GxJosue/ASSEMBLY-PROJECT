section .data
    menu_msg db 'Seleccione una figura:', 0xA, '1. Triangulo', 0xA, '2. Rectangulo', 0xA, 0
    msg_len equ $ - menu_msg
    invalid_msg db 'Opcion invalida.', 0xA, 0
    prompt db 'Ingrese su opcion:  ', 0

    base_prompt db 'Ingrese la base del triangulo: ', 0
    base_prompt_len equ $ - base_prompt
    height_prompt db 'Ingrese la altura del triangulo: ', 0
    height_prompt_len equ $ - height_prompt
    result_msg db 'El area del triangulo es: ', 0
    result_msg_len equ $ - result_msg
    newline db 0xA
    newline_len equ $ - newline
    ; Define el carácter de punto decimal
    dot db '.', 0
section .text
    global _start
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
print_float:
    push eax            ; Guardar eax
    push ecx            ; Guardar ecx

    mov edx, eax        ; Copiar el número flotante a edx

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
    mul ecx             ; Multiplicar el número flotante por 10
    mov ecx, edx       ; Mover el residuo a ecx (necesario para la parte decimal)
    mov eax, ecx       ; Mover la parte decimal a eax

    ; Imprimir la parte decimal
    call print_int      ; Llamar a la función print_int para imprimir la parte decimal

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
    mov ebx, height     ; Pasar la dirección de la altura a atoi
    call atoi

    mov [height_val], eax ; Guardar el valor convertido

        ; Calcular el área del triángulo
    mov eax, [base_val]
    imul eax, [height_val]

    ; Verificar si el resultado de la multiplicación es un número par o impar
    test eax, 1      ; Comprobar si el bit menos significativo está encendido
    jnz .odd_result  ; Si es impar, saltar a .odd_result

    ; Si el resultado es par, entonces la división por 2 puede realizarse sin problemas
    mov ebx, 2
    xor edx, edx    ; Limpiar edx antes de la división
    idiv ebx        ; Dividir por 2
    jmp .area_calculated  ; Saltar al final del cálculo del área

    .odd_result:
    mov ebx, 2
    xor edx, edx    ; Limpiar edx antes de la división
    idiv ebx        ; Dividir por 2
    inc eax         ; Sumar 1 al resultado de la división

    .area_calculated:
    mov [area], eax ; Guardar el área en [area]


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
    ; Aquí iría el código para la opción del rectángulo
    ; Puedes implementarlo después
    jmp exit_program

exit_program:
    ; Salir del programa
    mov eax, 1          ; syscall para sys_exit
    xor ebx, ebx        ; código de salida 0
    int 0x80            ; llamar al kernel

section .bss
    option resb 1       ; buffer para almacenar la opción del usuario
    base resb 10
    height resb 10
    base_val resd 1
    height_val resd 1
    area resd 1