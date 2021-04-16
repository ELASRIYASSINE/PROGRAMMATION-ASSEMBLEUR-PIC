;------------   Exemple d'application avec un PIC : Un clignotant    ---------------

; Titre : Clignotant
; Date : 01 JUILLET 2000
; Auteur : P.MAYEUX
; PIC utilisé : PIC 16 F 84
; On réalise un clignotant sur la broche RB0  d' un PIC 16 C 84 le quartz est de 4 
; Mhz , on effectue une tempo environ égale à 0.2 seconde. 
; un bouton marche sur le port A permet de lancer le clignotant à une 1 ère fréquence. 
; un 2 ème bouton permet d' obtenir une 2 eme fréquence
; un 3 ème bouton permet d' obtenir une 3 eme fréquence

;------------   Directive d' assemblage pour MPLAB   ---------------

	list	p=16f84A
	#include p16f84A.inc

;------------   Définition des constantes   ---------------

#define	inter0	0		; bouton marche
#define inter1	1		; bouton 1 ere fréquence
#define inter2	2		; bouton 2 ere fréquence
					
;------------   Définition des registres temporaires   ---------------

retard1		EQU        0x0C      ;	 le registre temporaire retard1 se trouve à l' adresse 0C
tp2		EQU        0x10      ; 	le registre temporaire tp2 se trouve à l' adresse 10
retard2		EQU        0x0F      ;	 le registre temporaire retard1 se trouve à l' adresse 0F
memo		EQU        0x12      ;	 le registre temporaire memo se trouve à l' adresse 12
	
;------------   Init des ports A et B   ---------------

          ORG     0       		; on assemble à partir de l'adresse 0
	  
          BSF STATUS,5	; on met à 1 le 5eme bit du registre status pour accéder
    				; à la 2eme page mémoire ( pour trisa et trisb )

          MOVLW 0x00  	; on met 00 dans le registre W
          MOVWF TRISB  	; on met 00 dans le port B il est programmé en sortie

          MOVLW 0x1F 	; on met 1F dans le registre W
          MOVWF TRISA   	; on met 1F dans le port A il est programmé en entrée
	  
          BCF STATUS,5	; on remet à 0 le 5eme bit du registre status pour accéder	
				; à la 1eme page mémoire 


;------------   raz de la led et du registre memo  ---------------


         MOVLW  0x00              ; on met 00 dans le registre W
         MOVWF  PORTB          ; on met W sur le port B ( led )
         MOVWF  memo            ; on met W dans le registre memo
         MOVWF tp2                 ; on met W dans le registre tp2

;------------   Programme principal   ---------------
debut
 	
	 btfss PORTA,inter0	; interrupteur 0 ( marche ) appuyé ? si oui on continu sinon 
	 goto debut 		; va à debut 

; -------------------- Test des inters ----------------------
         btfss PORTA,inter1	; interrupteur 1 ( freq 1 ) appuyé ? si non on va à suite
         goto suite
         MOVLW 0x01             ; on met 01 dans le registre W
         MOVWF tp2               ; on met W dans le registre tp2 

suite	 

         btfss PORTA,inter2     ; interrupteur 2 ( freq 2 ) appuyé ? si oui va à freq2 			
         goto suite2
         MOVLW 0x02             ; on met 02 dans le registre W
         MOVWF tp2               ; on met W dans le registre tp2 

suite2


         MOVLW 0xFF            ; on met ff dans le registre W
         MOVWF retard1         ; on met W dans le registre retard1 ( 1 ere fréquence )
         MOVWF retard2         ; on met W dans le registre retard2 ( 1 ere fréquence )
         
         MOVLW 0xAA            ; on met AA dans le registre W ( 2 eme fréquence )
         btfsc tp2,0	            ; on test le bit 0 de tp2 si = 1 alors on saute la prochaine 					;instruction
         MOVWF retard2          ; sinon on met W dans le registre retard2 ( 2 ere fréquence )

         MOVLW 0x55              ; on met 55 dans le registre W ( 3 eme fréquence )
         btfsc tp2,1	            ; on test le bit 1 de tp2 si = 1 alors on saute la prochaine 					; instruction
         MOVWF retard2          ; sinon on met W dans le registre retard2 ( 3 ere fréquence )

         COMF memo,F 		; On effectue le complément du registre memo et 
         MOVF memo,W           ; on met le resultat dans W	
         MOVWF  PORTB        ; on met W sur le port B ( leds )
         CALL  tempo               ; on appel la temporisation
         GOTO  debut               ; retour au début du programme


;------------   Programme de temporisation    ---------------

tempo

          DECFSZ retard1,F       ; on décrémente retard1 et on saute la prochaine instruction si 
          GOTO  tempo              ; le registre retard1 = 0 sinon retour à tempo

          movlw 0xFF		 ; on recharge retard1
          movwf retard1

          DECFSZ retard2,F       ; on décrémente retard2 et on saute la prochaine instruction si 
          GOTO  tempo              ; le registre retard2 = 0 sinon retour à tempo


          movlw 0x00	  	 ; On met 0 dans TP2
          movwf tp2
	  
          RETURN                  ; retour au programme principal après l 'instruction CALL

          END
 






