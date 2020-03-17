.include "macros.s""
.global  main

/*
Variables persistantes
*/

main:
	//Lecture de la chaine de caractere
    adr     x0, fmtLecture
    adr     x1, chaine
    bl      scanf

	//Lecture du code de Commande
	adr		x0, fmtNum
	adr		x1, code
	bl		scanf
	ldr		x20, code

//Section pour le switch case de selection
	cmp 	x20, 0
	b.eq	Taille
	cmp		x20, 1
	b.eq	Casse
	cmp		x20, 2
	b.eq	Hexa
	cmp		x20, 3
	b.eq	Bin
	cmp		x20, 4
	b.eq	Decalage
	cmp		x20, 5
	b.eq	Permutation
	b		Fin

//Section pour l'appel des fonction

Taille:
	mov		x0, chaine			//Placer chaine caractere dans x0
	bl		TrouverTaille		//Appeller la fonction pour trouver la taille, celle ci sera dans x1
	adr		x0, fmtSortieNum	//Afficher le nombre de caractere en sortie
	bl		printf
	b 		Fin
Casse:
	b		Fin
Hexa:
	b		Fin
Bin:
	b		Fin
Decalage:
	b		Fin
Permutation:
	b		Fin


//Section pour les fonction

/*
FCT : Trouver taille
Entree : debut d'une chaine de caractère en UTF8 x0
Sortie : nombre de caractères UTF8 dans x1
*/
TrouverTaille:
	SAVE
	mov		x19, 0			//Compteur de tour de boucle (Compte par le fait meme les caractères)
	mov		x20, x0			//Iterateur de tableau
F1Boucle:
	cmp		x20, 0 			//Verifier si caractere nul
	b.eq	F1Sortie		//Si nul, sortie
	add		x19, x19, 1		//Sinon, incrementer compteur, aller au caractère suivant
	add		x20, x20, 1		//Incrementation pour du ASCII
	//Interpretation du UTF8, incrementation de x20(savoir ou se placer dans le tableau) en conséquence
	b		F1Boucle
F1Sortie:
	mov 	x1, x19
	RESTORE
	ret










Fin:
    mov     x0, 0
    bl      exit

.section ".data"
// Mémoire allouée pour une chaîne de caractères d'au plus 1024 octets
code:		.skip	8
chaine:     .skip   1024

.section ".rodata"
// Format pour lire une chaîne de caractères d'une ligne (incluant des espaces)
fmtNum:			.asciz	"%lu"
fmtLecture: 	.asciz  "%[^\n]s"
fmtSortieNum: 	.asciz  "%lu\n"
