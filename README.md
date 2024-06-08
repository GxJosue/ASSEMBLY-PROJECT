
# Proyecto Final

El proyecto final consta de un programa hecho en lenguaje ensamblador utilizando NASM y utilizando un sistema de 32 bits.

### Proyecto 4: Cálculo de áreas de formas geométricas.
- Mostrar un menú de opciones para realizar el cálculo de área de las siguientes figuras geométricas:
    - Rectángulo
    - Triangulo
- Las variables de cada cálculo de área de cada forma, deberán de ser ingresadas en el formato de entero y por medio del teclado.
- El resultado deberá de expresarse con dos posiciones decimales.
- Aplicar el uso de macro o etiquetas en la llamada y transferencia de control de las instrucciones a ejecutar.


## Uso

Comandos a utilizar para correr el proyecto:

```terminal
nasm -f elf32 proyecto.asm -o proyecto.o
```
```terminal
ld -m elf_i386 proyecto.o -o proyecto
```
```terminal
./proyecto
```

## Alumnos

- [Gabriel Alexander Calderón Villeda - CV22022](https://github.com/ga-b0)

