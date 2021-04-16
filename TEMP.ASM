;-----   Application avec un PIC 16F628 : Gestion d 'un seuil de température ------

; Titre : gestion d 'un seuil de température
; Date : 08 Avril 2002
; Auteur : P.M
; PIC utilisé : PIC 16 F 628
; Ce montage d'initiation à base de PIC 16F628 va mettre en oeuvre les comparateurs
; de tension analogiques intégrés au PIC 16F628. Le montage compare les deux seuils 
; de tension prédéfinis à la tension issue d 'un capteur de température de type LM 335.
; Si le premier seuil est atteint on valide une sortie ( led jaune ), si la température
; continue d 'évoluer et si le deuxième seuil est atteint on valide une deuxième sortie
; ( led rouge )


;------------   Directive d' assemblage pour PLAB   ---------------

	list	p=16f628
	#include p16f628.inc
	__config H'3F18'   	

; config = ;Horloge interne, Code protect off,mode haute tension (lvp=0)

 
;------------   Définition des constantes   ---------------

W      			     EQU     0x00        ; variable W = 0 
F	 		     EQU     0x01        ; variable F = 1
inter			     EQU     0x00	 ; inter = 0 ( broche RB0 )
					
;------------   Définition des registres temporaires   ---------------

retard1      EQU        0x20      ; le registre temporaire retard1 pour la temporisation
retard2      EQU        0x21      ; le registre temporaire retard2 pour la temporisation

;***************   Numero de version  ***************

	org h'2100'
	de "Gestion d 'un seuil de température ver 1.0 08/04/02 "

;***********************   Programme principal  *******************************

	ORG 0

; ------ Programme d' INITIALISATION -------

	bcf STATUS,6
	bsf STATUS,5		; on met à 1 le 5eme bit du registre status pour accéder
    				; à la 2eme page mémoire ( pour trisa et trisb )
	MOVLW B'00000001'     	; rb1-rb7 en sortie rb0 en entrée
	MOVWF TRISB           	; on met 00 dans le port B il est programmé partiellement en sortie

	MOVLW B'00001111'       ; on met 0F dans le registre W
	MOVWF TRISA           	; on met 0F dans le port A il est programmé partiellement en sortie 
	bcf STATUS,5		; on remet à 0 le 5eme bit du registre status pour accéder	
				; à la 1eme page mémoire 

	MOVLW B'00110100'       ; on met 34 dans le registre W
	MOVWF CMCON           	; on met 34 dans le registre CMCON ( fonction utilisée : mode 4 )



;********************* Attente de l 'appui sur l 'inter *****************

init 
	btfsc PORTB,inter	; interrupteur marche - arrêt  appuyé ? si oui on  
	        		;va à l ' étiquette debut
	goto debut
	GOTO init
debut

	BSF PORTB,1
	call tempo

	BCF PORTB,1
	call tempo

	movf CMCON,W
	andlw B'11000000'
	movwf PORTB
	
	goto init




;********************** Temporisation courte T1 *************************

tempo
	MOVLW 0xff               ; on met ff dans le registre W
	MOVWF retard1            ; on met W dans le registre retard1 
	MOVWF retard2            ; on met W dans le registre retard2 

attente

	DECFSZ retard1,F         ; on décrémente retard1 et on saute la prochaine instruction si 
	GOTO  attente            ; le registre retard1 = 0 sinon retour à l 'étiquette 'attente'

	movlw 0xff		 ; on recharge retard1 avec 90
	movwf retard1

	DECFSZ retard2,F         ; on décrémente retard2 et on saute la prochaine instruction si 
	GOTO  attente            ; le registre retard2 = 0 sinon retour à l 'étiquette 'attente'

	return

	end	 
