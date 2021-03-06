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
	adr		x0, chaine
	bl		ChangerMot
	adr		x0, fmtSortieChaine
	adr		x1, chaine
	bl		printf
	b		Fin
Hexa:
	adr		x0, chaine
	bl		HexaEnDecimal
	adr 	x0, fmtSortieNum
	bl 		printf
	b		Fin
Bin:
	adr		x0, chaine
	bl		BinEnDec
	adr 	x0, fmtSortieNumSigne
	bl 		printf
	b		Fin
Decalage:
	adr		x0, chaine
	bl		CodeSecret
	adr		x0, fmtSortieChaine
	adr		x1, chaine
	bl		printf
	b		Fin
Permutation:
	adr		x0, chaine
	bl		Permutate
	adr		x0, fmtSortieChaine
	adr		x1, chaine
	bl		printf
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

/*
FCT : ChangerMot
Entree : debut d'une chaine de caractère en AScii x0
Sortie : Change directement la chaine envoyé
*/
ChangerMot:
	SAVE
	mov		x19, 0  		//Boolean pair/impair
	mov		x20, 0 			//Iterateur tableau
	mov		x20, x0
	sub		x20, x20, 1		//Offset de 1, pour que la boucle puisse incrementer la memoire sans if
F2Boucle:
	add		x20, x20, 1		//incremente avant loading, car possible modif a la case
	ldrb	w21, [x20]
	mov		w23, 0
	cmp		w21, w23
	b.eq	F2Sortie  		//Fin de la chaine de caractère
	cmp		x19, xzr
	b.ne	F2Impair
F2Pair:
	mov		x19, 1			//Met indicateur a impair pour prochainne boucle
	mov		w23, 65
	cmp		w21, w23
	b.lo	F2Boucle		//Caractere speciaux, pas de modif
	mov		w23, 97
	cmp		w21, w23
	b.hs	F2Voyelle		//Si deja minuscule, va a la verif des voyelles speciales
	add		w21, w21, 32	//Transforme w21 en minuscule
	strb	w21, [x20]		//Modifie le caractere dans la chaine pour w21
	b		F2Voyelle
F2Impair:
	mov		x19, 0 			//Met indicateur a pair pour prochaine boucle
	mov		w23, 65
	cmp		w21, w23
	b.lo	F2Boucle		//Caractere speciaux, pas de modif
	mov		w23, 97
	cmp		w21, w23
	b.lo	F2Voyelle		//si deja majuscule, va a la verif des voyelles speciales
	sub		w21, w21, 32	//Transforme w21 en majuscule
	strb	w21, [x20]		//Modifie le caractere dans la chaine pour w21
	b		F2Voyelle
F2Voyelle:
	mov		w23, 65
	cmp		w21, w23
	b.ne	F2Next1
	mov		w23, 52
	ldrb	w23, [x20]
	b		F2Boucle
F2Next1:
	mov		w23, 97
	cmp		w21, w23
	b.ne	F2Next2
	mov		w23, 52
	strb	w23, [x20]
	b		F2Boucle
F2Next2:
	mov		w23, 69
	cmp		w21, w23
	b.ne	F2Next3
	mov		w23, 51
	strb	w23, [x20]
	b		F2Boucle
F2Next3:
	mov		w23, 101
	cmp		w21, w23
	b.ne	F2Next4
	mov		w23, 51
	strb	w23, [x20]
	b		F2Boucle
F2Next4:
	mov		w23, 73
	cmp		w21, w23
	b.ne	F2Next5
	mov		w23, 49
	strb	w23, [x20]
	b		F2Boucle
F2Next5:
	mov		w23, 105
	cmp		w21, w23
	b.ne	F2Next6
	mov		w23, 49
	strb	w23, [x20]
	b		F2Boucle
F2Next6:
	mov		w23, 79
	cmp		w21, w23
	b.ne	F2Next7
	mov		w23, 48
	strb	w23, [x20]
	b		F2Boucle
F2Next7:
	mov		w23, 111
	cmp		w21, w23
	b.ne	F2Boucle			//Pas une voyelle a modifié simplement
	mov		w23, 48
	strb	w23, [x20]
	b		F2Boucle
F2Sortie:
	RESTORE
	ret


/*
FCT : CodeSecret
Entree : debut d'une chaine de caractere en ASCII x0
Sortie : Change directement la chaine envoyé
*/
CodeSecret:
	SAVE
	mov		w19, 0  		//Temporaire
	mov		x20, x0 		//Iterateur tableau
	sub		x20, x20, 1		//Offset de 1, pour que la boucle puisse incrementer la memoire sans if
F3Boucle:
	add		x20, x20, 1		//incremente avant loading, car possible modif a la case
	ldrb	w21, [x20]		//Valeur courante
	mov		w19, 0
	cmp		w21, w19
	b.eq	F3Sortie  		//Fin de la chaine de caractère
	//Etape 1 : Extraire les 5 bit de poid faible,
	mov		w19, 31  		//Masque pour les 5 bits poid faible
	and		w22, w21, w19	//w22 contient les 5 bits de poids faible de la valeur courante
	//Etape 2 : Rotation circulaire de ces 5bits, de 3bits vers la droite
	ror		w23, w22, 3		//On place les 2bits de poid faible pour les extraire
	mov		w19, 3			//Masque pour les 2bits poid faible
	and		w24, w23, w19	//w24 contient maintenant le 2bits de poids faible
	ror		w23, w23, 27	//on place les bits 3 à 5 pour l'extraction [27 car on est dans un registre de 32 bit pas un octet]
	mov		w19, 28			//Masque pour les 3bits suivante a allé cherché
	and		w25, w23, w19	//W25 contient les 3 autres bits de poids faible
	//Etape 3 : Extraire les 3 bits de poids fort
	mov		w19, 224		//Preparation du masque pour aller chercher les 3 bits de poid fort
	and		w26, w21, w19	//w26 contient les 3 bits de poid fort
	//Etape 4 : Additionner les 3 extractions ensemble (5 faible apres rotation + 3 fort initial)
	orr		w24, w24, w25
	orr		w24, w24, w26 	//Normalement, rendu ici, on a reconstruit les la rotationt d'encryptage dans w24
	//Etape 5 : Reculer de 7 lettre dans l'alphabet (Si ABCDEFG [<72], on additionne plutot de 19)
	mov		w19, 72
	cmp		w24, w19
	b.lo	F3Debordement
	sub		w24, w24, 7
	strb	w24, [x20]
	b		F3Boucle
F3Debordement:
	add 	w24, w24, 19
	strb	w24, [x20]
	b		F3Boucle
F3Sortie:
	RESTORE
	ret

/*
FCT : Hexadecimale en decimale
Entree : debut d'une chaine de caractere representant un nbre hexadecimale
 	en commencant par 0x
Sortie : Nbre converti en decimal
*/
HexaEnDecimal:
	SAVE
	mov		x19, x0  		//Position iterateur du tableau
	bl		TrouverTaille	// Trouver nbre chars dans mot
	mov 	x20, x1			// nbreChars
	sub 	x21, x20, 2		// nbre de nbreHexa
	mov 	x28, 0			// sum contiendra nbre decimale
	mov 	x22, 0			// i=0 (compteur nbre char)
	mov 	x23, 0			// j=0 (compteur pour power)
	mov 	x24, 1			// contiendra 16^i
	mov		x25, 16			// necessaire pour mul
F4Boucle:
	cmp 	x22, x21		// if(i==nbreHexa)
	b.eq	SortieHexa
F4Power:
	cmp 	x23, x22		// if(i==j)
	b.eq 	F4Sum
	mul		x24, x24, x25
	add 	x23, x23, 1
	b		F4Power
F4Sum:
	// x26 contient la position finalement utilise pour indexe
	add		x26, x20, 0		// prend en compte index partant de 0 et 0x
	sub		x26, x26, x22	// doit enlever i
	sub 	x26, x26, 1
	ldrb 	w27, [x19, x26]	// charger un char a la position det.
AsciiToDec:
	cmp 	w27, 57
	mov 	x3, 0
	b.le	ZeroToNine
	b 		AtoF
ZeroToNine:
	add 	x5, x3, 48		// Valeur ascii 0-9: 48-57
	mov 	x4, x3			// dupl. single reg for both branches (0-9 or A-F)
	cmp 	x5, x27
	b.eq	ValLoad
	add 	x3, x3, 1
	b 		ZeroToNine
AtoF:
	add 	x5, x3, 65		// Valeur ascii A-F: 65-70
	add 	x4, x3, 10		// x4 contient nombre convertie
	cmp		x5, x27
	b.eq	ValLoad
	add 	x3, x3, 1
	b 		AtoF
ValLoad:
	mul 	x27, x4, x24	// a*16^i
	add		x28, x28, x27	// sum+=a*16^i
	add 	x22, x22, 1		// i += 1
	b 		F4Boucle
SortieHexa:
	mov 	x1, x28
	RESTORE
	ret

/*
FCT : Binaire en decimale
Entree : debut d'une chaine de caractere representant un nbre binaire
 	en commencant par 0b
Sortie : Nbre converti en decimal
*/
BinEnDec:
	SAVE
	mov		x19, x0  		//Position iterateur du tableau
	bl		TrouverTaille	// Trouver nbre chars dans mot
	mov 	x20, x1			// nbreChars
	sub		x22, x20, 2		// nbre de chiffres binaires
	mov 	x4, 2			// position du premier chiffre bin
	mov 	x5, 49			// 1 en ascii

	ldrb	w21, [x19, x4]	// w21 contient bit de signes
	mov		x27, 0			// negatif par defaut avant branchement

	cmp 	x21, x5			// if(x21==1)
	b.eq 	FirstNonNeg		//
	mov 	x27, 1			// positif si pas branche
	b		NbreCharPos
FirstNonNeg:
	add 	x4, x4, 1		// x4+=1
	ldrb	w21, [x19, x4]	// load prochain chiffre
	cmp 	x21, x5			// if(val!=1)
	b.ne 	NbreCharNeg
	b 		FirstNonNeg
NbreCharNeg:
	sub 	x4, x4, 1		// revenir au 1 juste avant le dernier 0
	sub 	x3, x20, x4		// nbre de chiffre pour addition
	b 		CalculSomme
NbreCharPos:
	mov		x3, x22			// dupl. pour utiliser reg simple
CalculSomme:
	mov 	x28, 0			// somme
	mov		x23, 0			// iterateur
	mov 	x24, 2
	mov 	x25, 0			// iterateur power
	mov 	x26, 1			// pour power^0
BouclePower:
	cmp 	x23, x3
	b.eq 	SortieBin		// condition arret sum
	cmp		x3, x25
	b.eq	BoucleSomme		// condition autre nombre
	cmp 	x25, 0
	b.eq 	FirstPower		// condition premier nombre droit
	mul 	x26, x26, x24	// prochaine puissance de 2
FirstPower:
	add		x25, x25, 1
BoucleSomme:
	add		x23, x23, 1		// incrementer iterateur
	sub		x2, x20, x23	// position relatif a la fin du nombre bin
	ldrb	w21, [x19, x2]
	cmp 	x21, x5			// if(w21==x5)
	b.ne	DontAdd
	add 	x28, x28, x26
DontAdd:
	b 		BouclePower
SortieBin:
	mov 	x1, x28
	cmp		x27, 1
	b.eq	SortieBin1
	neg		x1, x1
SortieBin1:
	RESTORE
	ret


/*
FCT : Permutation d'une chaine de characteres
Entree : Chaines de characteres
Sortie : L'ensemble des permutations possibles
(Sert comme coquille d'appels vers PermutateFonc)
*/
Permutate:
	SAVE
	mov		x19, x0  		// Pointeur du tableau
	mov 	x27, x19
	bl		TrouverTaille	// Trouver nbre chars dans mot
	mov		x28, x1			// const taille
	sub		x2, x1, 1		// righTidx starts at 0
	mov 	x1, 0			// leftIdx
	bl 		PermutateR
	RESTORE
	ret
PermutateR:
	SAVE
	mov		x20, 0			// iterateur
	cmp 	x1, x2			// if(rightIdx == leftIdx)
	b.eq	SortiePermutateR
BouclePermute:
	// conditions
	cmp 	x20, x1			// if(i smaller than leftIdx)
	b.lo	incI
	add		x3, x2, 1
	cmp 	x20, x3			// if(i greater rightIdx+1)
	b.ge	SortiePermutateR

	add 	x23, x20, x28	// ajouter taille
	add		x24, x1, x28	// ajouter taille
	add		x25, x2, 1		// ajouter taille
	ldrb	w22, [x19, x23]	// load val du compteur
	ldrb	w21, [x19, x24]	// load val de leftIdx
	mov 	x26, 32			// stocker valeur de l'espace ascii
	strb	w25, [x19, x25]	// mettre esapce a la fin
	strb	w22, [x19, x24]	// swap(w22, w21)
	strb	w21, [x19, x23]	//

	add		x1, x1, 1		// leftIdx += 1
	add		x27, x27, 3			// doit loader mot changer ici
	bl		PermutateR		// permutate(string, leftIdx+1, rightIdx)
	sub		x1, x1, 1		// remettre leftIdx a val initiale

	add 	x23, x20, x28	// ajouter taille
	add		x24, x1, x28	// ajouter taille
	add		x25, x2, 1		// ajouter taille
	ldrb	w22, [x19, x23]	// load val du compteur
	ldrb	w21, [x19, x24]	// load val de leftIdx
	mov 	x26, 32			// stocker valeur de l'espace ascii
	strb	w25, [x19, x25]	// mettre esapce a la fin
	strb	w22, [x19, x24]	// swap(w22, w21)
	strb	w21, [x19, x23]	//
incI:
	add		x20, x20, 1		// i+=1
	b		BouclePermute
SortiePermutateR:
	RESTORE
	ret

Fin:
    mov     x0, 0
    bl      exit

.section ".data"
// Mémoire allouée pour une chaîne de caractères d'au plus 1024 octets
code:		.skip	8
chaine:     .skip   1024
newChaine:	.skip	1024

.section ".rodata"
// Format pour lire une chaîne de caractères d'une ligne (incluant des espaces)
fmtNum:				.asciz	"%lu"
fmtLecture: 		.asciz  "%[^\n]s"
fmtSortieNum: 		.asciz  "%lu\n"
fmtSortieNumSigne:	.asciz	"%ld\n"
fmtSortieChaine:	.asciz  "%s\n"
