;------------   Exemple d'application avec un PIC : Un chennillard   ---------------

; Titre : Chennillard
; Date : 01 JUILLET 2000
; Auteur : P.M
; PIC utilisé : PIC 16 F 84
; On réalise un chennillard sur les broches RB0 à RB5  d' un PIC 16 F 84 
; le quartz est de 4 Mhz , on effectue une tempo  environ égale à 0.2 seconde 
; un bouton marche sur le port A permet de lancer l' application 

;------------   Directive d' assemblage pour PLAB   ---------------

	list	p=16f84A
	#include p16f84A.inc
	__config H'3FF9'   

;------------   Définition des constantes   ---------------


#define inter0 0	   ; bouton marche
					
;------------   Définition des registres    ---------------

retard1      EQU        0x0C      ; le registre temporaire retard1 se trouve à l' adresse 0C
retard2      EQU        0x0F      ; le registre temporaire retard2 se trouve à l' adresse 0F
memo	  EQU        0x10      ; le registre temporaire memo se trouve à l' adresse 10


;------------   Init des ports A et B   ---------------

	ORG 0
	  
	bsf STATUS,5		; on met à 1 le 5eme bit du registre status pour accéder
    				; à la 2eme page mémoire ( pour trisa et trisb )

	MOVLW 0x00            	; on met 00 dans le registre W
	MOVWF TRISB           	; on met 00 dans le port B il est programmé en sortie

	MOVLW 0x1F            	; on met 1F dans le registre W
	MOVWF TRISA           	; on met 1F dans le port A il est programmé en entrée
	
	bcf STATUS,5		; on remet à 0 le 5eme bit du registre status pour accéder	
				; à la 1eme page mémoire 

;------------   Init des leds  et registre ---------------


	CLRF  PORTB              ; on met 0 sur le port B ( leds )
	MOVLW  01	      ; on met 01 dans le registre W 
	MOVWF  memo             ; on met W dans le registre memo

;--------------------   Programme principal   ----------------------

debut


	btfss PORTA,inter0	              ; interrupteur 0 ( marche ) appuyé ? si oui on continu sinon 
	        		              ;va à debut
	goto debut

	movf memo,W		; on met memo dans W
	movwf PORTB		; on met W sur le port B ( leds )


	CALL  tempo                       ; on appel la temporisation 

	RLF memo, F	             ; rotation à gauche du registre memo

	GOTO  debut                       ; retour au début du programme


;------------   Programme de temporisation longue   ---------------

tempo
	MOVLW 0xff             ; on met ff dans le registre W
	MOVWF retard1         ; on met W dans le registre retard1 
	MOVWF retard2         ; on met W dans le registre retard2 

attente

	DECFSZ retard1,F       ; on décrémente retard1 et on saute la prochaine instruction si 
	GOTO  attente            ; le registre retard1 = 0 sinon retour à tempo

	movlw 0xFF	     ; on recharge retard1
	movwf retard1

	DECFSZ retard2,F       ; on décrémente retard2 et on saute la prochaine instruction si 
	GOTO  attente            ; le registre retard2 = 0 sinon retour à tempo

	  
	RETURN                   ; retour au programme principal après l 'instruction CALL

	END
 






