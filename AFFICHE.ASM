;------   Exemple d'application avec un PIC : La commande d'un afficheur 7 segments -------

; Titre : Commande d'un afficheur 7 segments
; Date : 01 JUILLET 2000
; Auteur : P.M
; PIC utilisé : PIC 16 F 84
; On réalise l ' allumage des 7 segments d'un afficheur sur les broches RB0 à RB7  
; d' un PIC 16 F 84. Chaque broche pilote un segment. On fera compter l' afficheur 
; de 0 à F. Dès que l 'afficheur arrive à A on allume le point décimal.
; le quartz est de 4 Mhz , on effectue une tempo environ égale à 0.2 secondes 
; un bouton marche sur le port A permet de lancer l' application 

; Il est également possible ( et plus facile ) de stocker des valeur prédéfinies en E²PROM et de les
; transférer vers les segments de l 'afficheur.

;------------   Directive d' assemblage pour PLAB   ---------------

	list	p=16f84A
	#include p16f84A.inc
	__config H'3FF9'   

 
;------------   Définition des constantes   ---------------

#define inter0 0	   ; bouton marche
					
;------------   Définition des registres temporaires   ---------------

retard1      EQU        0x0C      ; le registre temporaire retard1 se trouve à l' adresse 0C
retard2      EQU        0x0F      ; le registre temporaire retard2 se trouve à l' adresse 0F


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

;------------   Init de l'afficheur à 0  ---------------


	MOVLW  B'01110111'       ; on met 77 dans le registre W ( Affiche le 0 )
	MOVWF  PORTB             ; on met W sur le port B ( led )

;--------------------   Programme principal   ----------------------

debut

	MOVLW  B'01110111'       ; on met 77 dans le registre W ( Affiche le 0 )
	MOVWF  PORTB              ; on met W sur le port B ( segments )

	btfss PORTA,inter0           ; interrupteur 0 ( marche ) appuyé ? si oui on continu sinon 
	        		          ;va à debut
	goto debut


	MOVLW  B'01000001'       ; on met 41 dans le registre W ( Affiche le 1 )
	MOVWF  PORTB              ; on met W sur le port B ( segments )


	CALL  tempo                    ; on appel la temporisation 1 ( longue )
         
	MOVLW  B'00111011'       ; on met 3B dans le registre W ( Affiche le 2 )
	MOVWF  PORTB              ; on met W sur le port B ( segments )

	CALL  tempo                    ; on appel la temporisation 1 ( longue )

	MOVLW  B'01101011'       ; on met 6B dans le registre W ( Affiche le 3 )
	MOVWF  PORTB              ; on met W sur le port B ( segments )

	CALL  tempo                    ; on appel la temporisation 

	MOVLW  B'01001101'       ; on met 4D dans le registre W ( Affiche le 4 )
	MOVWF  PORTB              ; on met W sur le port B ( segments )

	CALL  tempo                    ; on appel la temporisation 

	MOVLW  B'01101110'       ; on met 6E dans le registre W ( Affiche le 5 )
	MOVWF  PORTB              ; on met W sur le port B ( segments )

	CALL  tempo                    ; on appel la temporisation longue

	MOVLW  B'01111110'       ; on met 7E dans le registre W ( Affiche le 6 )
	MOVWF  PORTB              ; on met W sur le port B ( segments )

	CALL  tempo                    ; on appel la temporisation 

	MOVLW  B'01000011'       ; on met 43 dans le registre W ( Affiche le 7 )
	MOVWF  PORTB              ; on met W sur le port B ( segments )

	CALL  tempo                    ; on appel la temporisation 

	MOVLW  B'01111111'       ; on met 7F dans le registre W ( Affiche le 8 )
	MOVWF  PORTB              ; on met W sur le port B ( segments )

	CALL  tempo                    ; on appel la temporisation 

	MOVLW  B'01101111'       ; on met 6F dans le registre W ( Affiche le 9 )
	MOVWF  PORTB              ; on met W sur le port B ( segments )

	CALL  tempo                    ; on appel la temporisation 

	MOVLW  B'11011111'       ; on met DF dans le registre W ( Affiche le A )
	MOVWF  PORTB              ; on met W sur le port B ( segments )

	CALL  tempo                    ; on appel la temporisation 

	MOVLW  B'01111100'       ; on met 7C dans le registre W ( Affiche le B )
	MOVWF  PORTB              ; on met W sur le port B ( segments )

	CALL  tempo                    ; on appel la temporisation 

	MOVLW  B'00110110'       ; on met 36 dans le registre W ( Affiche le C )
	MOVWF  PORTB              ; on met W sur le port B ( segments )

	CALL  tempo                     ; on appel la temporisation 

	MOVLW  B'01111001'       ; on met 79 dans le registre W ( Affiche le D )
	MOVWF  PORTB              ; on met W sur le port B ( segments )

	CALL  tempo                    ; on appel la temporisation 

	MOVLW  B'00111110'       ; on met 3E dans le registre W ( Affiche le E )
	MOVWF  PORTB              ; on met W sur le port B ( segments )

	CALL  tempo                    ; on appel la temporisation 

	MOVLW  B'00011110'       ; on met 1E dans le registre W ( Affiche le F )
	MOVWF  PORTB              ; on met W sur le port B ( segments )

	CALL  tempo                    ; on appel la temporisation 

	GOTO  debut                   ; retour au début du programme


;------------   Programme de temporisation   ---------------

tempo
	MOVLW 0xff              ; on met ff dans le registre W
	MOVWF retard1         ; on met W dans le registre retard1 
	MOVWF retard2         ; on met W dans le registre retard2 

attente

	DECFSZ retard1,F       ; on décrémente retard1 et on saute la prochaine instruction si 
	GOTO  attente            ; le registre retard1 = 0 sinon retour à tempo

	movlw 0xFF	     ; on recharge retard1
	movwf retard1

	DECFSZ retard2,F       ; on décrémente retard2 et on saute la prochaine instruction si 
	GOTO  attente            ; le registre retard2 = 0 sinon retour à tempo
  
	RETURN                    ; retour au programme principal après l 'instruction CALL


	END
 






