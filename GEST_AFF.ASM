;-----   Application avec un PIC : Gestion d 'un afficheur 2 fois 16 caract�res ------

; Titre : gestion d 'un afficheur
; Date : 02 Janvier 2002
; Auteur : P.M
; PIC utilis� : PIC 16 F 84
; Ce montage d'initiation � base de PIC 16C84 permet de g�rer un afficheur de deux foix 16
; caract�res � acc�s parall�le, dans ce montage on affichera un message enregsitr� en E�PROM
; d�s que l 'interrupteur marche-arr�t sera actionn�.

; +++++++++++++ configuration : ++++++++++++++++++

; les broches rb0 � rb7 sont configur�es en sortie elles pilotent les broches
; DB0 � DB7 de l 'afficheur.
; les broches RA0 � RA3 sont en sortie la broche RA2 pilote la broche RS de l 'afficheur
; la broche RA4 est en entr�e elle est connect�e � l 'interrupteur marche-arr�t.

;------------   Directive d' assemblage pour PLAB   ---------------

	list	p=16f84A
	#include p16f84A.inc
	__config H'3FF9'   

;------------   D�finition des constantes   ---------------

W      			     EQU     0x00        ; variable W = 0 
F	 		     EQU     0x01        ; variable F = 1
inter			     EQU     0x04	 ; inter = 4 ( broche RA4 )
rs			     EQU     0x03        ; la broche rs est sur RA3
e			     EQU     0x02        ; la broche e est sur RA2
					
;------------   D�finition des registres temporaires   ---------------

retard1      EQU        0x0C      ; le registre temporaire retard1 pour la temporisation
retard2      EQU        0x0D      ; le registre temporaire retard2 pour la temporisation

;***************   Numero de version  ***************

	org h'2100'
	de "Gestion d 'un afficheur ver 1.0 12/01/02 "

;***********************   Programme principal  *******************************

	ORG 0

; ------ Programme d' INIT -------

	bsf STATUS,5		; on met � 1 le 5eme bit du registre status pour acc�der
    				; � la 2eme page m�moire ( pour trisa et trisb )
	MOVLW B'00000000'     	; rb0-rb7 en sortie
	MOVWF TRISB           	; on met 00 dans le port B il est programm� en sortie

	MOVLW B'11110000'       ; on met f0 dans le registre W
	MOVWF TRISA           	; on met f0 dans le port A il est programm� en sortie ra4 en entr�e
	bcf STATUS,5		; on remet � 0 le 5eme bit du registre status pour acc�der	
				; � la 1eme page m�moire 
	
	clrf PORTA
	clrf PORTB
	
	call top_h

; ******************* Configuration de l 'afficheur *********************

;mode de fonctionnement 8 bits de donn�es

init
	bsf PORTA,e		; le bit e est mis � 1
	bcf PORTA,rs		; la broche rs de l 'afficheur � 0 
				; pour envoyer une commande
	
	MOVLW B'00111000'       ; on met 38 dans le registre W
	MOVWF PORTB          	; acc�s 8 bits , 2 lignes pour l 'afficheur
	call top_h	

	MOVLW B'00000001'       ; on met 01 dans le registre W
	MOVWF PORTB          	; reset afficheur (clear display)
	call top_h	

	MOVLW B'00001110'       ; on met 0E dans le registre W
	MOVWF PORTB          	; display 'on' et cursor 'on'
	call top_h

	MOVLW B'00000110'       ; on met 06 dans le registre W
	MOVWF PORTB          	; incr�mentation du curseur vers la droite
	call top_h

	MOVLW B'10000010'       ; on met la dd ram � l'adresse 02
	MOVWF PORTB          	; le curseur clignote � la 1ere rang�e digit 3
	call top_h

	bsf PORTA,rs		; on repasse la broche rs de l 'afficheur � 1 
				; pour le fonctionnement normal en data

;********************* Attente de l 'appui sur l 'inter *****************

debut 
	btfsc PORTA,inter	; interrupteur marche - arr�t  appuy� ? si oui on  
	        		;va � l ' �tiquette affiche
	goto affiche
	GOTO debut
	
;********************** top d 'horloge **********************************

top_h

	call tempo		; on appel le sous-programme de temporisation
	bcf PORTA,e		; le bit e est mis � 0
	call tempo 
	bsf PORTA,e		; le bit e est mis � 1
	return

;********************** Temporisation courte T1 *************************

tempo
	MOVLW 0xff               ; on met ff dans le registre W
	MOVWF retard1            ; on met W dans le registre retard1 
	MOVWF retard2            ; on met W dans le registre retard2 

attente

	DECFSZ retard1,F         ; on d�cr�mente retard1 et on saute la prochaine instruction si 
	GOTO  attente            ; le registre retard1 = 0 sinon retour � l '�tiquette 'attente'

	movlw 0x90		 ; on recharge retard1 avec 90
	movwf retard1

	DECFSZ retard2,F         ; on d�cr�mente retard2 et on saute la prochaine instruction si 
	GOTO  attente            ; le registre retard2 = 0 sinon retour � l '�tiquette 'attente'
	 
	RETURN                   ; retour au programme principal apr�s l 'instruction CALL

affiche

; ******************* Envoie du message sur l 'afficheur *********************

	bsf PORTA,0	; on allume la led connect�e sur RA0

	MOVLW 'G'       ; on met le caract�re 'G' dans le registre W
	MOVWF PORTB     ; on transfert le contenu du registre W sur le port B (vers l 'afficheur)
	call top_h

	MOVLW 'e'       ; on met le caract�re 'e' dans le registre W
	MOVWF PORTB     ; on transfert le contenu du registre W sur le port B (vers l 'afficheur)
	call top_h
	
	MOVLW 's'       ; on met le caract�re 's' dans le registre W
	MOVWF PORTB     ; on transfert le contenu du registre W sur le port B (vers l 'afficheur)
	call top_h
	
	MOVLW 't'       ; on met le caract�re 't' dans le registre W
	MOVWF PORTB     ; on transfert le contenu du registre W sur le port B (vers l 'afficheur)
	call top_h
	
	MOVLW 'i'       ; on met le caract�re 'i' dans le registre W
	MOVWF PORTB     ; on transfert le contenu du registre W sur le port B (vers l 'afficheur)
	call top_h
	
	MOVLW 'o'       ; on met le caract�re 'o' dans le registre W
	MOVWF PORTB     ; on transfert le contenu du registre W sur le port B (vers l 'afficheur)
	call top_h
	
	MOVLW 'n'       ; on met le caract�re 'n' dans le registre W
	MOVWF PORTB     ; on transfert le contenu du registre W sur le port B (vers l 'afficheur)
	call top_h

	MOVLW ' '       ; on met le caract�re ' ' dans le registre W
	MOVWF PORTB     ; on transfert le contenu du registre W sur le port B (vers l 'afficheur)
	call top_h

	MOVLW 'd'       ; on met le caract�re 'd' dans le registre W
	MOVWF PORTB     ; on transfert le contenu du registre W sur le port B (vers l 'afficheur)
	call top_h
	
	MOVLW 0x27      ; on met le caract�re ''' dans le registre W
	MOVWF PORTB     ; on transfert le contenu du registre W sur le port B (vers l 'afficheur)
	call top_h
	
	MOVLW 'u'       ; on met le caract�re 'u' dans le registre W
	MOVWF PORTB     ; on transfert le contenu du registre W sur le port B (vers l 'afficheur)
	call top_h
	
	MOVLW 'n'       ; on met le caract�re 'n' dans le registre W
	MOVWF PORTB     ; on transfert le contenu du registre W sur le port B (vers l 'afficheur)
	call top_h

	MOVLW ' '       ; on met le caract�re ' ' dans le registre W
	MOVWF PORTB     ; on transfert le contenu du registre W sur le port B (vers l 'afficheur)
	call top_h


; saut sur la 2eme rang�e

	bcf PORTA,rs		; on repasse la broche rs de l 'afficheur � 0 
				; pour envoyer une commande

	MOVLW B'11000011'       ; on met la dd ram � l'adresse 43
	MOVWF PORTB          	; le curseur se trouve donc sur la 2eme rang�e digit 4
	call top_h

	bsf PORTA,rs		; on repasse la broche rs de l 'afficheur � 1 
				; pour le fonctionnement normal en data
	
	MOVLW 'A'       ; on met le caract�re 'A' dans le registre W
	MOVWF PORTB     ; on transfert le contenu du registre W sur le port B (vers l 'afficheur)
	call top_h
	
	MOVLW 'f'       ; on met le caract�re 'f' dans le registre W
	MOVWF PORTB     ; on transfert le contenu du registre W sur le port B (vers l 'afficheur)
	call top_h
	
	MOVLW 'f'       ; on met le caract�re 'f' dans le registre W
	MOVWF PORTB     ; on transfert le contenu du registre W sur le port B (vers l 'afficheur)
	call top_h

	MOVLW 'i'       ; on met le caract�re 'i' dans le registre W
	MOVWF PORTB     ; on transfert le contenu du registre W sur le port B (vers l 'afficheur)
	call top_h
	
	MOVLW 'c'       ; on met le caract�re 'c' dans le registre W
	MOVWF PORTB     ; on transfert le contenu du registre W sur le port B (vers l 'afficheur)
	call top_h
	
	MOVLW 'h'       ; on met le caract�re 'h' dans le registre W
	MOVWF PORTB     ; on transfert le contenu du registre W sur le port B (vers l 'afficheur)
	call top_h
	
	MOVLW 'e'       ; on met le caract�re 'e' dans le registre W
	MOVWF PORTB     ; on transfert le contenu du registre W sur le port B (vers l 'afficheur)
	call top_h


	MOVLW 'u'       ; on met le caract�re 'u' dans le registre W
	MOVWF PORTB     ; on transfert le contenu du registre W sur le port B (vers l 'afficheur)
	call top_h
	
	MOVLW 'r'       ; on met le caract�re 'r' dans le registre W
	MOVWF PORTB     ; on transfert le contenu du registre W sur le port B (vers l 'afficheur)
	call top_h
	

boucle 

	btfsc PORTA,inter	; interrupteur marche - arr�t  appuy� ? si oui on  
	        		; va � l ' �tiquette boucle
	goto boucle

	bcf PORTA,0		; on eteint la led

	GOTO init		; on retourne � l 'init de l 'afficheur

	END
 






