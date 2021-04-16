;------------   Exemple d'application avec un PIC : La perçeuse   ---------------

; Titre : Perçeuse
; Date : 01 JUILLET 2000
; Auteur : P.M
; PIC utilisé : PIC 16 F 84
; On réalise une simulation d' une perçeuse en utilisant les broches RB0 à RB3 
; pour le bouton marche, le coup de poing d' arrêt d'urgence et les deux fin de
; course haut et bas.
; Les broches RB4 à RB7 représentent la rotation, la montée et la descente.

; Entrées : RB0= Arrêt     RA0= Marche     RA1= Capteur haut    RA2= Capteur bas
; Sorties : RB1= Rotation  RB2= Descente   RB3= Montée	        RB4= Défaut mémorisé 

; Cycle : 
; 1) appui sur marche -> rotation + descente
; 2) capteur bas actionné -> temporisation et rotation + remontée
; 3) capteur haut actionné -> rotation + temporisation et arret rotation

; Arrêt d'urgence : La perceuse s'arrête de tourner et remonte, un voyant défaut mémorise
; l' action. Le voyant défaut s' efface au prochain cycle.

;------------   Directive d' assemblage pour PLAB   ---------------

	list	p=16f84A
	#include p16f84A.inc
	__config H'3FF9'   

 
;------------   Définition des constantes   ---------------

#define arret 0	   	 ; bouton arrêt
#define marche 0	               ; bouton marche
#define capteur_h 1	 ; capteur haut
#define capteur_b 2	 ; capteur bas

					
;------------   Définition des registres temporaires   ---------------

retard1      EQU        0x0C      ; le registre temporaire retard1 se trouve à l' adresse 0C
retard2      EQU        0x0F      ; le registre temporaire retard2 se trouve à l' adresse 0F
retard3      EQU        0x10      ; le registre temporaire retard3 se trouve à l' adresse 10

; -------------------------------------------- Saut à init --------------------------------------------------------------------

	org 0

	goto init


;-----------------------------------------   Programme d' interruption   ----------------------------------------------

	org 04

	MOVLW  B'00011000'           ; on met 18 dans le registre W ( montée + voyant défaut )
	MOVWF  PORTB                  ; on met W sur le port B ( led )
	
capt
	btfss PORTA,capteur_h	; interrupteur 1 ( capteur haut ) appuyé ? si non on  
	goto capt   		; va à capt
	
	MOVLW  B'00010000'           ; on met 10 dans le registre W ( voyant defaut )
	MOVWF  PORTB                  ; on met W sur le port B ( led )

	bcf INTCON,1		; on met à 0 le 1er bit de INTCON
	bsf INTCON,4		; on met à 1 le 4eme bit du registre INTCON pour autoriser l' IT sur RB0
	bsf INTCON,7		; on met à 1 le 7eme bit du registre INTCON pour autoriser toutes les 'IT 
	
              goto debut		; on retourne à debut

;----------------------------------   Init des ports A et B et validation des IT  ------------------------------------

init
	ORG 20
	  
	bsf STATUS,5		; on met à 1 le 5eme bit du registre status pour accéder
    				; à la 2eme page mémoire ( pour trisa et trisb )

	MOVLW 0x01            	; on met 01 dans le registre W
	MOVWF TRISB           	; on met 00 dans le port B il est programmé en sortie sauf RB0

	MOVLW 0x1F            	; on met 1F dans le registre W
	MOVWF TRISA           	; on met 1F dans le port A il est programmé en entrée
	
	bcf STATUS,5		; on remet à 0 le 5eme bit du registre status pour accéder	
				; à la 1eme page mémoire 
	
	bsf INTCON,4		; on met à 1 le 4eme bit du registre INTCON pour autoriser
				; l 'IT sur la broche RB0 ( arrêt d 'urgence )

	bsf INTCON,7		; on met à 1 le 7eme bit du registre INTCON pour autoriser toutes les 'IT 


;----------------------------------------------   Programme principal   ------------------------------------------------------

	MOVLW  B'00000000'           ; on met 00 dans le registre W ( arret )
	MOVWF  PORTB                  ; on met W sur le port B ( led )

debut
	bsf INTCON,4		; on met à 1 le 4eme bit du registre INTCON
	bsf INTCON,7		; on met à 1 le 7eme bit du registre INTCON			
				; toutes les 'IT 

	btfsc PORTB,arret	              ; interrupteur 0 ( arret ) appuyé ? si oui on  
	goto debut   		; va à debut
	

	btfss PORTA,marche	; interrupteur 0 ( marche ) appuyé ? si oui on continu sinon 
	goto debut     		; va à debut
	

	btfss PORTA,capteur_h	; interrupteur 1 ( capteur haut ) appuyé ? si non on  
	goto debut     		; va à debut ( init )
	
	MOVLW  B'00000000'            ; on met 00 dans le registre W ( arret )
	MOVWF  PORTB                   ; on met W sur le port B ( led )


	MOVLW  B'00000110'            ; on met 06 dans le registre W ( Rotation + descente )
	MOVWF  PORTB                   ; on met W sur le port B ( led )

descente

	btfss PORTA,capteur_b	; interrupteur 2 ( capteur bas ) appuyé ? si non on  
	goto descente 		; va à descente
	

	CALL  tempo                        ; on appel la temporisation 
         
	MOVLW  B'00001010'           ; on met 0A dans le registre W ( Rotation + montée )
	MOVWF  PORTB                  ; on met W sur le port B ( led )

remonte
	
	btfss PORTA,capteur_h	; interrupteur 1 ( capteur haut ) appuyé ? si non on  
	goto remonte   		; va à remonte
	
	CALL  tempo                        ; on appel la temporisation 

	MOVLW  B'00000010'           ; on met 02 dans le registre W ( Rotation )
	MOVWF  PORTB                  ; on met W sur le port B ( led )

	CALL  tempo                        ; on appel la temporisation 

	MOVLW  B'00000000'           ; on met 00 dans le registre W ( arret )
	MOVWF  PORTB                  ; on met W sur le port B ( led )

	GOTO  debut                       ; retour au début du programme


;----------------------------------------------   Programme de temporisation    ----------------------------------------------------

tempo
	MOVLW 0xFF            ; on met ff dans le registre W
	MOVWF retard1         ; on met W dans le registre retard1 
	MOVWF retard2         ; on met W dans le registre retard2 
	MOVLW 0x12            ; on met 12 dans le registre W
	MOVWF retard3         ; on met W dans le registre retard3 

attente

	DECFSZ retard1,F       ; on décrémente retard1 et on saute la prochaine instruction si 
	GOTO  attente            ; le registre retard1 = 0 sinon retour à tempo

	movlw 0xFF	     ; on recharge retard1
	movwf retard1

	DECFSZ retard2,F       ; on décrémente retard2 et on saute la prochaine instruction si 
	GOTO  attente            ; le registre retard2 = 0 sinon retour à tempo

	movlw 0xFF	      ; on recharge retard2
	movwf retard2

	DECFSZ retard3,F       ; on décrémente retard3 et on saute la prochaine instruction si 
	GOTO  attente            ; le registre retard3 = 0 sinon retour à tempo
	  
	RETURN                    ; retour au programme principal après l 'instruction CALL


	END
 






