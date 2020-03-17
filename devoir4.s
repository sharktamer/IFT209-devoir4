.include "macros.s"
.global  main

main:
    adr     x0, fmtLecture
    adr     x1, chaine
    bl      scanf

    mov     x0, 0
    bl      exit

.section ".data"
// Mémoire allouée pour une chaîne de caractères d'au plus 1024 octets
chaine:     .skip   1024

.section ".rodata"
// Format pour lire une chaîne de caractères d'une ligne (incluant des espaces)
fmtLecture: .asciz  "%[^\n]s"
