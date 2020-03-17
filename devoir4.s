.include "macros.s"
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
	adr		x0, chaine			//Placer l'adresse du debut de la chaine de caractere dans x0
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
	ldrb	w21, [x20]
	cmp		w21, 0			//Verifier si caractere nul
	b.eq	F1Sortie		//Si nul, sortie
	add		x19, x19, 1		//Sinon, incrementer compteur, aller au caractère suivant
	add		x20, x20, 1		//Incrementation pour du ASCII
	//Interpretation du UTF8, incrementation de x20(savoir ou se placer dans le tableau) en conséquence
	tbz		w21, 7, F1Boucle  //Si l'octet a un 1 a la position 7, le caractere est sur plus d'un octet en UTF8
	add		x20, x20, 3		  //On place l'incrementation au maximum (4)
	//On applique successivement les masques pour obtenir la bonne incrementation
	mov		w23, 240
	and		w22, w21, w23	  //On copie dans x22 les 2 bits de poids fort de w21 a l'aide du masque w3
	cmp		w22, w23		  //Si les 4 bits de poid fort son allumé
	b.eq	F1Boucle		  //Le caractere s'affichait sur 4 octet, on retourne dans la boucle
	sub		x20, x20, 1		  //Sinon, on decremente et on test pour 3 octet
	mov		w23, 224
	and		w22, w21, w23
	cmp		w22, w23
	b.eq	F1Boucle		 //Sinon, c'etait sur 2 octets
	sub 	x20, x20, 1
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
