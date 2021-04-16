;-----   Application avec un PIC : Gestion d 'un afficheur 2 fois 16 caractères ------

; Titre : gestion d 'un afficheur
; Date : 02 Janvier 2002
; Auteur : P.M
; PIC utilisé : PIC 16 F 84
; Ce montage d'initiation à base de PIC 16C84 permet de gérer un afficheur de deux foix 16
; caractères à accés parallèle, dans ce montage on affichera un message enregsitré en E²PROM
; dès que l 'interrupteur marche-arrêt sera actionné.

; +++++++++++++ configuration : ++++++++++++++++++

; les broches rb0 à rb7 sont configurées en sortie elles pilotent les broches
; DB0 à DB7 de l 'afficheur.
; les broches RA0 à RA3 sont en sortie la broche RA2 pilote la broche RS de l 'afficheur
; la broche RA4 est en entrée elle est connectée à l 'interrupteur marche-arrêt.

;------------   Directive d' assemblage pour PLAB   ---------------

	list	p=16f84A
	#include p16f84A.inc
	__config H'3FF9'   

;------------   Définition des constantes   ---------------

W      			     EQU     0x00        ; variable W = 0 
F	 		     EQU     0x01        ; variable F = 1
inter			     EQU     0x04	 ; inter = 4 ( broche RA4 )
rs			     EQU     0x03        ; la broche rs est sur RA3
e			     EQU     0x02        ; la broche e est sur RA2
					
;------------   Définition des registres temporaires   ---------------

retard1      EQU        0x0C      ; le registre temporaire retard1 pour la temporisation
retard2      EQU        0x0D      ; le registre temporaire retard2 pour la temporisation

;***************   Numero de version  ***************

	org h'2100'
	de "Gestion d 'un afficheur ver 1.0 12/01/02 "

;***********************   Programme principal  *******************************

	ORG 0

; ------ Programme d' INIT -------

	bsf STATUS,5		; on met à 1 le 5eme bit du registre status pour accéder
    				; à la 2eme page mémoire ( pour trisa et trisb )
	MOVLW B'00000000'     	; rb0-rb7 en sortie
	MOVWF TRISB           	; on met 00 dans le port B il est programmé en sortie

	MOVLW B'11110000'       ; on met f0 dans le registre W
	MOVWF TRISA           	; on met f0 dans le port A il est programmé en sortie ra4 en entrée
	bcf STATUS,5		; on remet à 0 le 5eme bit du registre status pour accéder	
				; à la 1eme page mémoire 
	
	clrf PORTA
	clrf PORTB
	
	call top_h

; ******************* Configuration de l 'afficheur *********************

;mode de fonctionnement 8 bits de données

init
	bsf PORTA,e		; le bit e est mis à 1
	bcf PORTA,rs		; la broche rs de l 'afficheur à 0 
				; pour envoyer une commande
	
	MOVLW B'00111000'       ; on met 38 dans le registre W
	MOVWF PORTB          	; accès 8 bits , 2 lignes pour l 'afficheur
	call top_h	

	MOVLW B'00000001'       ; on met 01 dans le registre W
	MOVWF PORTB          	; reset afficheur (clear display)
	call top_h	

	MOVLW B'00001110'       ; on met 0E dans le registre W
	MOVWF PORTB          	; display 'on' et cursor 'on'
	call top_h

	MOVLW B'00000110'       ; on met 06 dans le registre W
	MOVWF PORTB          	; incrémentation du curseur vers la droite
	call top_h

	MOVLW B'10000010'       ; on met la dd ram à l'adresse 02
	MOVWF PORTB          	; le curseur clignote à la 1ere rangée digit 3
	call top_h

	bsf PORTA,rs		; on repasse la broche rs de l 'afficheur à 1 
				; pour le fonctionnement normal en data

;********************* Attente de l 'appui sur l 'inter *****************

debut 
	btfsc PORTA,inter	; interrupteur marche - arrêt  appuyé ? si oui on  
	        		;va à l ' étiquette affiche
	goto affiche
	GOTO debut
	
;********************** top d 'horloge **********************************

top_h

	call tempo		; on appel le sous-programme de temporisation
	bcf PORTA,e		; le bit e est mis à 0
	call tempo 
	bsf PORTA,e		; le bit e est mis à 1
	return

;********************** Temporisation courte T1 *************************

tempo
	MOVLW 0xff               ; on met ff dans le registre W
	MOVWF retard1            ; on met W dans le registre retard1 
	MOVWF retard2            ; on met W dans le registre retard2 

attente

	DECFSZ retard1,F         ; on décrémente retard1 et on saute la prochaine instruction si 
	GOTO  attente            ; le registre retard1 = 0 sinon retour à l 'étiquette 'attente'

	movlw 0x90		 ; on recharge retard1 avec 90
	movwf retard1

	DECFSZ retard2,F         ; on décrémente retard2 et on saute la prochaine instruction si 
	GOTO  attente            ; le registre retard2 = 0 sinon retour à l 'étiquette 'attente'
	 
	RETURN                   ; retour au programme principal après l 'instruction CALL

affiche

; ******************* Envoie du message sur l 'afficheur *********************

	bsf PORTA,0	; on allume la led connectée sur RA0

	MOVLW 'G'       ; on met le caractère 'G' dans le registre W
	MOVWF PORTB     ; on transfert le contenu du registre W sur le port B (vers l 'afficheur)
	call top_h

	MOVLW 'e'       ; on met le caractère 'e' dans le registre W
	MOVWF PORTB     ; on transfert le contenu du registre W sur le port B (vers l 'afficheur)
	call top_h
	
	MOVLW 's'       ; on met le caractère 's' dans le registre W
	MOVWF PORTB     ; on transfert le contenu du registre W sur le port B (vers l 'afficheur)
	call top_h
	
	MOVLW 't'       ; on met le caractère 't' dans le registre W
	MOVWF PORTB     ; on transfert le contenu du registre W sur le port B (vers l 'afficheur)
	call top_h
	
	MOVLW 'i'       ; on met le caractère 'i' dans le registre W
	MOVWF PORTB     ; on transfert le contenu du registre W sur le port B (vers l 'afficheur)
	call top_h
	
	MOVLW 'o'       ; on met le caractère 'o' dans le registre W
	MOVWF PORTB     ; on transfert le contenu du registre W sur le port B (vers l 'afficheur)
	call top_h
	
	MOVLW 'n'       ; on met le caractère 'n' dans le registre W
	MOVWF PORTB     ; on transfert le contenu du registre W sur le port B (vers l 'afficheur)
	call top_h

	MOVLW ' '       ; on met le caractère ' ' dans le registre W
	MOVWF PORTB     ; on transfert le contenu du registre W sur le port B (vers l 'afficheur)
	call top_h

	MOVLW 'd'       ; on met le caractère 'd' dans le registre W
	MOVWF PORTB     ; on transfert le contenu du registre W sur le port B (vers l 'afficheur)
	call top_h
	
	MOVLW 0x27      ; on met le caractère ''' dans le registre W
	MOVWF PORTB     ; on transfert le contenu du registre W sur le port B (vers l 'afficheur)
	call top_h
	
	MOVLW 'u'       ; on met le caractère 'u' dans le registre W
	MOVWF PORTB     ; on transfert le contenu du registre W sur le port B (vers l 'afficheur)
	call top_h
	
	MOVLW 'n'       ; on met le caractère 'n' dans le registre W
	MOVWF PORTB     ; on transfert le contenu du registre W sur le port B (vers l 'afficheur)
	call top_h

	MOVLW ' '       ; on met le caractère ' ' dans le registre W
	MOVWF PORTB     ; on transfert le contenu du registre W sur le port B (vers l 'afficheur)
	call top_h


; saut sur la 2eme rangée

	bcf PORTA,rs		; on repasse la broche rs de l 'afficheur à 0 
				; pour envoyer une commande

	MOVLW B'11000011'       ; on met la dd ram à l'adresse 43
	MOVWF PORTB          	; le curseur se trouve donc sur la 2eme rangée digit 4
	call top_h

	bsf PORTA,rs		; on repasse la broche rs de l 'afficheur à 1 
				; pour le fonctionnement normal en data
	
	MOVLW 'A'       ; on met le caractère 'A' dans le registre W
	MOVWF PORTB     ; on transfert le contenu du registre W sur le port B (vers l 'afficheur)
	call top_h
	
	MOVLW 'f'       ; on met le caractère 'f' dans le registre W
	MOVWF PORTB     ; on transfert le contenu du registre W sur le port B (vers l 'afficheur)
	call top_h
	
	MOVLW 'f'       ; on met le caractère 'f' dans le registre W
	MOVWF PORTB     ; on transfert le contenu du registre W sur le port B (vers l 'afficheur)
	call top_h

	MOVLW 'i'       ; on met le caractère 'i' dans le registre W
	MOVWF PORTB     ; on transfert le contenu du registre W sur le port B (vers l 'afficheur)
	call top_h
	
	MOVLW 'c'       ; on met le caractère 'c' dans le registre W
	MOVWF PORTB     ; on transfert le contenu du registre W sur le port B (vers l 'afficheur)
	call top_h
	
	MOVLW 'h'       ; on met le caractère 'h' dans le registre W
	MOVWF PORTB     ; on transfert le contenu du registre W sur le port B (vers l 'afficheur)
	call top_h
	
	MOVLW 'e'       ; on met le caractère 'e' dans le registre W
	MOVWF PORTB     ; on transfert le contenu du registre W sur le port B (vers l 'afficheur)
	call top_h


	MOVLW 'u'       ; on met le caractère 'u' dans le registre W
	MOVWF PORTB     ; on transfert le contenu du registre W sur le port B (vers l 'afficheur)
	call top_h
	
	MOVLW 'r'       ; on met le caractère 'r' dans le registre W
	MOVWF PORTB     ; on transfert le contenu du registre W sur le port B (vers l 'afficheur)
	call top_h
	

boucle 

	btfsc PORTA,inter	; interrupteur marche - arrêt  appuyé ? si oui on  
	        		; va à l ' étiquette boucle
	goto boucle

	bcf PORTA,0		; on eteint la led

	GOTO init		; on retourne à l 'init de l 'afficheur

	END
 






