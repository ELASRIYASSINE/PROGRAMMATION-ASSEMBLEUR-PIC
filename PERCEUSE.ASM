;------------   Exemple d'application avec un PIC : La per�euse   ---------------

; Titre : Per�euse
; Date : 01 JUILLET 2000
; Auteur : P.M
; PIC utilis� : PIC 16 F 84
; On r�alise une simulation d' une per�euse en utilisant les broches RB0 � RB3 
; pour le bouton marche, le coup de poing d' arr�t d'urgence et les deux fin de
; course haut et bas.
; Les broches RB4 � RB7 repr�sentent la rotation, la mont�e et la descente.

; Entr�es : RB0= Arr�t     RA0= Marche     RA1= Capteur haut    RA2= Capteur bas
; Sorties : RB1= Rotation  RB2= Descente   RB3= Mont�e	        RB4= D�faut m�moris� 

; Cycle : 
; 1) appui sur marche -> rotation + descente
; 2) capteur bas actionn� -> temporisation et rotation + remont�e
; 3) capteur haut actionn� -> rotation + temporisation et arret rotation

; Arr�t d'urgence : La perceuse s'arr�te de tourner et remonte, un voyant d�faut m�morise
; l' action. Le voyant d�faut s' efface au prochain cycle.

;------------   Directive d' assemblage pour PLAB   ---------------

	list	p=16f84A
	#include p16f84A.inc
	__config H'3FF9'   

 
;------------   D�finition des constantes   ---------------

#define arret 0	   	 ; bouton arr�t
#define marche 0	               ; bouton marche
#define capteur_h 1	 ; capteur haut
#define capteur_b 2	 ; capteur bas

					
;------------   D�finition des registres temporaires   ---------------

retard1      EQU        0x0C      ; le registre temporaire retard1 se trouve � l' adresse 0C
retard2      EQU        0x0F      ; le registre temporaire retard2 se trouve � l' adresse 0F
retard3      EQU        0x10      ; le registre temporaire retard3 se trouve � l' adresse 10

; -------------------------------------------- Saut � init --------------------------------------------------------------------

	org 0

	goto init


;-----------------------------------------   Programme d' interruption   ----------------------------------------------

	org 04

	MOVLW  B'00011000'           ; on met 18 dans le registre W ( mont�e + voyant d�faut )
	MOVWF  PORTB                  ; on met W sur le port B ( led )
	
capt
	btfss PORTA,capteur_h	; interrupteur 1 ( capteur haut ) appuy� ? si non on  
	goto capt   		; va � capt
	
	MOVLW  B'00010000'           ; on met 10 dans le registre W ( voyant defaut )
	MOVWF  PORTB                  ; on met W sur le port B ( led )

	bcf INTCON,1		; on met � 0 le 1er bit de INTCON
	bsf INTCON,4		; on met � 1 le 4eme bit du registre INTCON pour autoriser l' IT sur RB0
	bsf INTCON,7		; on met � 1 le 7eme bit du registre INTCON pour autoriser toutes les 'IT 
	
              goto debut		; on retourne � debut

;----------------------------------   Init des ports A et B et validation des IT  ------------------------------------

init
	ORG 20
	  
	bsf STATUS,5		; on met � 1 le 5eme bit du registre status pour acc�der
    				; � la 2eme page m�moire ( pour trisa et trisb )

	MOVLW 0x01            	; on met 01 dans le registre W
	MOVWF TRISB           	; on met 00 dans le port B il est programm� en sortie sauf RB0

	MOVLW 0x1F            	; on met 1F dans le registre W
	MOVWF TRISA           	; on met 1F dans le port A il est programm� en entr�e
	
	bcf STATUS,5		; on remet � 0 le 5eme bit du registre status pour acc�der	
				; � la 1eme page m�moire 
	
	bsf INTCON,4		; on met � 1 le 4eme bit du registre INTCON pour autoriser
				; l 'IT sur la broche RB0 ( arr�t d 'urgence )

	bsf INTCON,7		; on met � 1 le 7eme bit du registre INTCON pour autoriser toutes les 'IT 


;----------------------------------------------   Programme principal   ------------------------------------------------------

	MOVLW  B'00000000'           ; on met 00 dans le registre W ( arret )
	MOVWF  PORTB                  ; on met W sur le port B ( led )

debut
	bsf INTCON,4		; on met � 1 le 4eme bit du registre INTCON
	bsf INTCON,7		; on met � 1 le 7eme bit du registre INTCON			
				; toutes les 'IT 

	btfsc PORTB,arret	              ; interrupteur 0 ( arret ) appuy� ? si oui on  
	goto debut   		; va � debut
	

	btfss PORTA,marche	; interrupteur 0 ( marche ) appuy� ? si oui on continu sinon 
	goto debut     		; va � debut
	

	btfss PORTA,capteur_h	; interrupteur 1 ( capteur haut ) appuy� ? si non on  
	goto debut     		; va � debut ( init )
	
	MOVLW  B'00000000'            ; on met 00 dans le registre W ( arret )
	MOVWF  PORTB                   ; on met W sur le port B ( led )


	MOVLW  B'00000110'            ; on met 06 dans le registre W ( Rotation + descente )
	MOVWF  PORTB                   ; on met W sur le port B ( led )

descente

	btfss PORTA,capteur_b	; interrupteur 2 ( capteur bas ) appuy� ? si non on  
	goto descente 		; va � descente
	

	CALL  tempo                        ; on appel la temporisation 
         
	MOVLW  B'00001010'           ; on met 0A dans le registre W ( Rotation + mont�e )
	MOVWF  PORTB                  ; on met W sur le port B ( led )

remonte
	
	btfss PORTA,capteur_h	; interrupteur 1 ( capteur haut ) appuy� ? si non on  
	goto remonte   		; va � remonte
	
	CALL  tempo                        ; on appel la temporisation 

	MOVLW  B'00000010'           ; on met 02 dans le registre W ( Rotation )
	MOVWF  PORTB                  ; on met W sur le port B ( led )

	CALL  tempo                        ; on appel la temporisation 

	MOVLW  B'00000000'           ; on met 00 dans le registre W ( arret )
	MOVWF  PORTB                  ; on met W sur le port B ( led )

	GOTO  debut                       ; retour au d�but du programme


;----------------------------------------------   Programme de temporisation    ----------------------------------------------------

tempo
	MOVLW 0xFF            ; on met ff dans le registre W
	MOVWF retard1         ; on met W dans le registre retard1 
	MOVWF retard2         ; on met W dans le registre retard2 
	MOVLW 0x12            ; on met 12 dans le registre W
	MOVWF retard3         ; on met W dans le registre retard3 

attente

	DECFSZ retard1,F       ; on d�cr�mente retard1 et on saute la prochaine instruction si 
	GOTO  attente            ; le registre retard1 = 0 sinon retour � tempo

	movlw 0xFF	     ; on recharge retard1
	movwf retard1

	DECFSZ retard2,F       ; on d�cr�mente retard2 et on saute la prochaine instruction si 
	GOTO  attente            ; le registre retard2 = 0 sinon retour � tempo

	movlw 0xFF	      ; on recharge retard2
	movwf retard2

	DECFSZ retard3,F       ; on d�cr�mente retard3 et on saute la prochaine instruction si 
	GOTO  attente            ; le registre retard3 = 0 sinon retour � tempo
	  
	RETURN                    ; retour au programme principal apr�s l 'instruction CALL


	END
 






