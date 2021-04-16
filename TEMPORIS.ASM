;------   Exemple d'application avec un PIC : Essai sur le temporisateur interne  -------

; Pour essayer le programme on utilisera la platine du clignotant

; Titre : TIMER du PIC
; Date : 01 JUILLET 2001
; Auteur : P.M
; PIC utilisé : PIC 16 F 84
; on utilise le timer pour avoir une temporisation multiple de la seconde
; si le registre OPTION = 
; 04 --> 1 S
; 05 --> 4 S
; 07 --> 8 S
; 03 --> 0.5 S
; 02 --> 0.25 S
; 01 --> 0.0125 S
; 00 --> 0.00625 S
; le timer fonctionne avec la fréquence interne Q = 4 MHz

;------------   Directive d' assemblage pour PLAB   ---------------

	list	p=16f84A
	#include p16f84A.inc
	__config H'3FF9'   

;------------   Définition des constantes   ---------------

W      			     EQU     0x00        ; variable W = 0 
F	 		     EQU     0x01        ; variable F = 1
					
;------------   Définition des registres temporaires   ---------------

retard1      EQU        0x0C      ; le registre temporaire retard1 se trouve à l' adresse 0C
key	     EQU	0x12
OPTION_REG   EQU        H'0081'

;------------   Init des ports A et B   ---------------


	ORG 0
	  
	bsf STATUS,5		; on met à 1 le 5eme bit du registre status pour accéder
    				; à la 2eme page mémoire ( pour trisa et trisb et OPTION )
	MOVLW 0x00            	; on met 00 dans le registre W
	MOVWF TRISB           	; on met 00 dans le port B il est programmé en sortie

	MOVLW 0x1F            	; on met 1F dans le registre W
	MOVWF TRISA           	; on met 1F dans le port A il est programmé en entrée

	MOVLW 0x07            	; on met 07 dans le registre W
	MOVWF OPTION_REG      	; on met 07 dans le registre OPTION ( 8 secondes )
				; 1MHz / 256 = 3.906 kHz

	bcf STATUS,5		; on remet à 0 le 5eme bit du registre status pour accéder	
				; à la 1eme page mémoire 
	clrf PORTB
	clrf key

;--------------------   Programme principal   ----------------------

debut
	 
	MOVLW 0x06            ; on met 06 dans le registre W
	MOVWF TMR0            ; on met W dans le registre du TIMER 0 
			      ; le timer comptera jusqu' à 256 - 6 = 250
			      ; 3.906 kHz / 250 = 15.624 Hz	

	MOVLW 0x7D            ; on met 7D ( 125 ) dans le registre W 
	MOVWF retard1         ; on met W dans le registre retard1 
			      ; 15.624 Hz / 125 = 0.124992 Hz et 1/0.12 = 8 S

	call tempo

	COMF key,f            ; on complémente le registre key
	movf key,w
	movwf PORTB	      ; change l 'état des leds à chaque fois que la tempo est finie

	goto debut


tempo
	movf TMR0,w
	btfss STATUS,2	      ;test du bit Z
	goto tempo

	MOVLW 0x06            ; on met 06 dans le registre W
	MOVWF TMR0            ; on met W dans le registre du TIMER 0

	DECFSZ retard1,F      ; on décrémente retard1 et on saute la prochaine instruction si 
	GOTO  tempo           ; le registre retard1 = 0 sinon retour à tempo

	return

	END
 






