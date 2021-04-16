;------------   Exemple d'application avec un PIC : Les feux tricolores   ---------------

; Titre : Feux tricolores
; Date : 01 JUILLET 2000
; Auteur : P.M
; PIC utilisé : PIC 16 F 84
; On réalise des feux tricolores sur les broches RB0 à RB5  d' un PIC 16 C 84 
; le quartz est de 4 Mhz , on effectue une tempo longue  environ égale à 4 secondes et 
; une tempo courte environ égale à 1.5 secondes. 
; un bouton marche sur le port A permet de lancer l' application 

; RB0=rouge1 RB1=orange1 RB2=vert1   
; RB3=rouge2 RB4=orange2 RB5=vert2   


;------------   Directive d' assemblage pour PLAB   ---------------

	list	p=16f84A
	#include p16f84A.inc
	__config H'3FF9'   

 
;------------   Définition des constantes   ---------------

#define inter0 0	   ; bouton marche
#define inter1 1	   ; bouton clignotement orange
					
;------------   Définition des registres temporaires   ---------------

retard1      EQU        0x0C      ; le registre temporaire retard1 se trouve à l' adresse 0C
retard2      EQU        0x0F      ; le registre temporaire retard2 se trouve à l' adresse 0F
retard3      EQU        0x10      ; le registre temporaire retard3 se trouve à l' adresse 10

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

;------------   Init des feux ROUGE1 et ROUGE2  ---------------


	MOVLW  B'00001001'      ; on met 0C dans le registre W ( Rouge1 et Rouge2 )
	MOVWF  PORTB          ; on met W sur le port B ( led )

;--------------------   Programme principal   ----------------------

debut

	MOVLW  B'00001001'           ; on met 0C dans le registre W ( Rouge1 et Rouge2 )
	MOVWF  PORTB                  ; on met W sur le port B ( led )

	btfss PORTA,inter0 	; interrupteur 0 ( marche ) appuyé ? si oui on continu sinon 
	        		              ;va à debut
	goto debut

ret_cli

	btfsc PORTA,inter1  	; interrupteur 1 ( clignotant ) appuyé ? si oui on  
	        		              ;va à clignote
	goto clignote

	MOVLW  B'00001001'          ; on met 0C dans le registre W ( Rouge1 et Rouge2 )
	MOVWF  PORTB                 ; on met W sur le port B ( led )

;--------------- Chargement de la temporisation ---------------------


	CALL  tempo                       ; on appel la temporisation 1 ( longue )
         
	MOVLW  B'00001100'          ; on met 0C dans le registre W ( Vert1 et Rouge2 )
	MOVWF  PORTB                 ; on met W sur le port B ( led )

	CALL  tempo                       ; on appel la temporisation 1 ( longue )

	MOVLW  B'00001010'         ; on met 0A dans le registre W ( Orange1 et Rouge2 )
	MOVWF  PORTB                ; on met W sur le port B ( led )

	CALL  tempo2                    ; on appel la temporisation courte

	MOVLW  B'00001001'         ; on met 0C dans le registre W ( Rouge1 et Rouge2 )
	MOVWF  PORTB                ; on met W sur le port B ( led )

	CALL  tempo2                    ; on appel la temporisation courte

	MOVLW  B'00100001'        ; on met 24 dans le registre W ( Rouge1 et Vert2 )
	MOVWF  PORTB               ; on met W sur le port B ( led )

	CALL  tempo                     ; on appel la temporisation longue

	MOVLW  B'00010001'        ; on met 14 dans le registre W ( Rouge1 et Orange2 )
	MOVWF  PORTB               ; on met W sur le port B ( led )

	CALL  tempo2                   ; on appel la temporisation courte


	GOTO  debut                    ; retour au début du programme


;------------   Programme de temporisation longue   ---------------

tempo
	MOVLW 0xFF            ; on met ff dans le registre W
	MOVWF retard1         ; on met W dans le registre retard1 
	MOVWF retard2         ; on met W dans le registre retard2 
	MOVLW 0x12            ; on met 12 dans le registre W
	MOVWF retard3         ; on met W dans le registre retard3 

attente

	DECFSZ retard1,F       ; on décrémente retard1 et on saute la prochaine instruction si 
	GOTO  attente            ; le registre retard1 = 0 sinon retour à attente

	movlw 0xFF	     ; on recharge retard1
	movwf retard1

	DECFSZ retard2,F       ; on décrémente retard2 et on saute la prochaine instruction si 
	GOTO  attente            ; le registre retard2 = 0 sinon retour à attente

	movlw 0xFF	     ; on recharge retard2
	movwf retard2

	DECFSZ retard3,F       ; on décrémente retard3 et on saute la prochaine instruction si 
	GOTO  attente            ; le registre retard3 = 0 sinon retour à attente
	  
	RETURN                    ; retour au programme principal après l 'instruction CALL
  

;------------   Programme de temporisation courte   ---------------

tempo2
	MOVLW 0xFF            ; on met ff dans le registre W
	MOVWF retard1         ; on met W dans le registre retard1 
	MOVWF retard2         ; on met W dans le registre retard2 
	MOVLW 0x07            ; on met 7 dans le registre W
	MOVWF retard3         ; on met W dans le registre retard3 

attente2

	DECFSZ retard1,F       ; on décrémente retard1 et on saute la prochaine instruction si 
	GOTO  attente2          ; le registre retard1 = 0 sinon retour à attente2

	movlw 0xFF                ; on recharge retard1
	movwf retard1

	DECFSZ retard2,F       ; on décrémente retard2 et on saute la prochaine instruction si 
	GOTO  attente2          ; le registre retard2 = 0 sinon retour à attente2

	movlw 0xFF	     ; on recharge retard2
	movwf retard2

	DECFSZ retard3,F       ; on décrémente retard3 et on saute la prochaine instruction si 
	GOTO  attente2          ; le registre retard3 = 0 sinon retour à attente2

	RETURN

clignote

	
	MOVLW  B'00010010'      ; on met 12 dans le registre W ( Orange1 et Orange2 )
	MOVWF  PORTB             ; on met W sur le port B ( led )

	CALL  tempo2                 ; on appel la temporisation courte

	MOVLW  B'00000000'      ; on met 00 dans le registre W ( aucune led )
	MOVWF  PORTB             ; on met W sur le port B ( led )

	CALL  tempo2                 ; on appel la temporisation courte

	goto ret_cli

	END
 






