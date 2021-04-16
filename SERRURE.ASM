;------   Exemple d'application avec un PIC : Une serrure codée -------

; Titre : Serrure codée
; Date : 01 janvier 2000
; Auteur : P.M
; PIC utilisé : PIC 16 F 84
; On réalise un décodage de clavier sur les broches RB0 à RB5 d' un PIC 16 F 84.
; Si la séquence des 4 touches appuyées correspond aux codes de l ' E²PROM alors
; on valide la sortie pendant 2 secondes.
; on utilise  la mémoire E²PROM pour stocker le code qui valide la sortie à relais


;------------   Directive d' assemblage pour PLAB   ---------------

	list	p=16f84A
	#include p16f84A.inc
	__config H'3FF9'   

 
;------------   Définition des constantes   ---------------

W      			     EQU     0x00        ; variable W = 0 
F	 		     EQU     0x01        ; variable F = 1
					
;------------   Définition des registres temporaires   ---------------

retard1      EQU        0x0C      ; le registre temporaire retard1 se trouve à l' adresse 0C
retard2      EQU        0x0F      ; le registre temporaire retard2 se trouve à l' adresse 0F
retard3	     EQU	0x14
tampon	     EQU	0x10	  ; le registre tampon est à l'adresse 10
rang	     EQU        0x11
key	     EQU	0x12

;------------   Mise en E²PROM des valeurs ---------------

	org H'2100'    			; Données EEPROM 
	DE  0x44,0x84,0x06,0x05, 0	; les 4 codes qui valident la sortie à relais

;------------   Init des ports A et B   ---------------

	ORG 0
	  
	bsf STATUS,5		; on met à 1 le 5eme bit du registre status pour accéder
    				; à la 2eme page mémoire ( pour trisa et trisb )

	MOVLW B'11000011'     	; on met C3 dans le registre W
	MOVWF TRISB           	; on met C3 dans le port B il est programmé partiellement en E/S

	MOVLW 0x00            	; on met 00 dans le registre W
	MOVWF TRISA           	; on met 00 dans le port A il est programmé en sortie
	
	bcf STATUS,5		; on remet à 0 le 5eme bit du registre status pour accéder	
				; à la 1eme page mémoire 

;------------   Init  ---------------


	MOVLW  00       	; on met 0 dans le registre W 
	MOVWF  PORTB            ; on met W sur le port B 
	MOVWF tampon		; on met 00 dans le registre tampon

init
	MOVLW  04       	; on met 4 dans le registre W 
	MOVWF  rang             ; on met W rang
        MOVLW 0x01           	; on met 01 dans le registre W led rouge
        MOVWF PORTA          	; on met 01 sur le port A

;--------------------   Programme principal   ----------------------

debut
	 bcf PORTA,2		; on met à 0 le CA2

	 movf rang,w		; on met rang dans W
 	 MOVWF  PORTB           ; on met W sur le port B ( N° rang= N° ligne alimentée )
	 
	 
	 BTFSC PORTB,6		; on teste le bit RB6 si = 0 on saute la prochaine instruction	
	 call sauve

	 BTFSC PORTB,7		; on teste le bit RB7 si = 0 on saute la prochaine instruction	
	 call sauve
	 
	 BTFSC PORTB,1		; on teste le bit RB1 si = 0 on saute la prochaine instruction	
	 call sauve
	 
	 BTFSC PORTB,0		; on teste le bit RB0 si = 0 on saute la prochaine instruction	
	 call sauve

 
	 movf rang,W		; on met rang dans W
	 SUBLW 0x20	        ; W - 32 -> W 
	 BTFSC STATUS,2		; on teste le bit Z si Z=0 on saute la prochaine instruction	
	 GOTO init

	 movf rang,W		; on met rang dans W
         ADDWF  rang, F		; on additionne rang + rang
 
	 GOTO debut

;------------   sauvegarde de la touche   ---------------

sauve
;	 bsf PORTA,2		; on met à 1 le CA2
	 movf PORTB,W		; on met le port B (clavier) dans W 
	 MOVWF key		; on sauve W dans key

	 MOVF  tampon, W       ; on met tampon dans W
         MOVWF  EEADR          ; on met W sur EEADR ( adresse E²PROM )
	 bsf STATUS,5	       ; on met à 1 le 5eme bit du registre status pour accéder
    			       ; à la 2eme page mémoire ( EECON1 )

         MOVLW 0x01            ; on met 01 dans le registre W
         MOVWF EECON1          ; on met 01 dans le registre EECON1
 	 bcf STATUS,5		; on remet à 0 le 5eme bit du registre status 
				
         MOVLW  0x01           ; on met 1 dans le registre W
         ADDWF  tampon, F      ; on additionne tampon + 1
                 
         MOVF  EEDATA, W       ; on met la donnée E²PROM dans W
 
	 SUBWF key,F	        ; key - W -> f ( la touche correspond à l' E²PROM ? )
	 BTFSS STATUS,2		; on teste le bit Z si Z=1 on saute la prochaine instruction	
	 GOTO raz

         MOVLW  0x04       	; on met 5 dans W
 
	 SUBWF tampon,W	        ; tampon - W -> W ( on a eu les 4 touches ? )
	 BTFSC STATUS,2		; on teste le bit Z si Z=0 on saute la prochaine instruction	 
	 goto ouvre


;---------------- test de l'appui maintenu ---------------------

appui
	 BTFSC PORTB,6		; on teste le bit RB6 si = 1 on va à appui	
	 GOTO appui
	 BTFSC PORTB,7		; on teste le bit RB7 si = 1 on va à appui	
	 GOTO appui
	 BTFSC PORTB,1		; on teste le bit RB1 si = 1 on va à appui	
	 GOTO appui
	 BTFSC PORTB,0		; on teste le bit RB0 si = 1 on va à appui	
	 GOTO appui

	 CALL tempo_c

	 goto debut

raz
         MOVLW 0x00            ; on met 00 dans le registre W
         MOVWF tampon          ; on met 01 dans le registre tampon
	 return

ouvre
         MOVLW 0x06           ; on met 06 dans le registre W
         MOVWF PORTA           ; on met 06 sur le port A ( led verte + relais )
	 call tempo
	 goto init

;------------   Programme de temporisation   ---------------

tempo
	MOVLW 0xFF            ; on met ff dans le registre W
	MOVWF retard1         ; on met W dans le registre retard1 
	MOVWF retard2         ; on met W dans le registre retard2 
	MOVLW 0x10            ; on met 03 dans le registre W
	MOVWF retard3         ; on met W dans le registre retard3 

attente

	DECFSZ retard1,F       ; on décrémente retard1 et on saute la prochaine instruction si 
	GOTO  attente            ; le registre retard1 = 0 sinon retour à tempo

	movlw 0xFF		 ; on recharge retard1
	movwf retard1

	DECFSZ retard2,F       ; on décrémente retard2 et on saute la prochaine instruction si 
	GOTO  attente            ; le registre retard2 = 0 sinon retour à tempo

	movlw 0xFF		 ; on recharge retard2
	movwf retard2

	DECFSZ retard3,F       ; on décrémente retard3 et on saute la prochaine instruction si 
	GOTO  attente            ; le registre retard3 = 0 sinon retour à tempo
	  
	RETURN                 ; retour au programme principal après l 'instruction CALL

;------------   Programme de temporisation courte  ---------------


tempo_c
	MOVLW 0x30            ; on met 10 dans le registre W
	MOVWF retard1         ; on met W dans le registre retard1 
	MOVWF retard2         ; on met W dans le registre retard2 

attend

	DECFSZ retard1,F       ; on décrémente retard1 et on saute la prochaine instruction si 
	GOTO  attend            ; le registre retard1 = 0 sinon retour à tempo

	movlw 0xFF		 ; on recharge retard1
	movwf retard1

	DECFSZ retard2,F       ; on décrémente retard2 et on saute la prochaine instruction si 
	GOTO  attend           ; le registre retard2 = 0 sinon retour à tempo

		  
	RETURN                 ; retour au programme principal après l 'instruction CALL

	END
 






