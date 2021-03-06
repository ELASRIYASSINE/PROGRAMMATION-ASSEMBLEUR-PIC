;-----   Application avec un PIC 16F628 : Gestion d 'un seuil de temp�rature ------

; Titre : gestion d 'un seuil de temp�rature
; Date : 08 Avril 2002
; Auteur : P.M
; PIC utilis� : PIC 16 F 628
; Ce montage d'initiation � base de PIC 16F628 va mettre en oeuvre les comparateurs
; de tension analogiques int�gr�s au PIC 16F628. Le montage compare les deux seuils 
; de tension pr�d�finis � la tension issue d 'un capteur de temp�rature de type LM 335.
; Si le premier seuil est atteint on valide une sortie ( led jaune ), si la temp�rature
; continue d '�voluer et si le deuxi�me seuil est atteint on valide une deuxi�me sortie
; ( led rouge )


;------------   Directive d' assemblage pour PLAB   ---------------

	list	p=16f628
	#include p16f628.inc
	__config H'3F18'   	

; config = ;Horloge interne, Code protect off,mode haute tension (lvp=0)

 
;------------   D�finition des constantes   ---------------

W      			     EQU     0x00        ; variable W = 0 
F	 		     EQU     0x01        ; variable F = 1
inter			     EQU     0x00	 ; inter = 0 ( broche RB0 )
					
;------------   D�finition des registres temporaires   ---------------

retard1      EQU        0x20      ; le registre temporaire retard1 pour la temporisation
retard2      EQU        0x21      ; le registre temporaire retard2 pour la temporisation

;***************   Numero de version  ***************

	org h'2100'
	de "Gestion d 'un seuil de temp�rature ver 1.0 08/04/02 "

;***********************   Programme principal  *******************************

	ORG 0

; ------ Programme d' INITIALISATION -------

	bcf STATUS,6
	bsf STATUS,5		; on met � 1 le 5eme bit du registre status pour acc�der
    				; � la 2eme page m�moire ( pour trisa et trisb )
	MOVLW B'00000001'     	; rb1-rb7 en sortie rb0 en entr�e
	MOVWF TRISB           	; on met 00 dans le port B il est programm� partiellement en sortie

	MOVLW B'00001111'       ; on met 0F dans le registre W
	MOVWF TRISA           	; on met 0F dans le port A il est programm� partiellement en sortie 
	bcf STATUS,5		; on remet � 0 le 5eme bit du registre status pour acc�der	
				; � la 1eme page m�moire 

	MOVLW B'00110100'       ; on met 34 dans le registre W
	MOVWF CMCON           	; on met 34 dans le registre CMCON ( fonction utilis�e : mode 4 )



;********************* Attente de l 'appui sur l 'inter *****************

init 
	btfsc PORTB,inter	; interrupteur marche - arr�t  appuy� ? si oui on  
	        		;va � l ' �tiquette debut
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

	DECFSZ retard1,F         ; on d�cr�mente retard1 et on saute la prochaine instruction si 
	GOTO  attente            ; le registre retard1 = 0 sinon retour � l '�tiquette 'attente'

	movlw 0xff		 ; on recharge retard1 avec 90
	movwf retard1

	DECFSZ retard2,F         ; on d�cr�mente retard2 et on saute la prochaine instruction si 
	GOTO  attente            ; le registre retard2 = 0 sinon retour � l '�tiquette 'attente'

	return

	end	 
