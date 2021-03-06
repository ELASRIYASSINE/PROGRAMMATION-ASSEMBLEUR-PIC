;------------   Exemple d'application avec un PIC : Un clignotant    ---------------

; Titre : Clignotant
; Date : 01 JUILLET 2000
; Auteur : P.MAYEUX
; PIC utilis� : PIC 16 F 84
; On r�alise un clignotant sur la broche RB0  d' un PIC 16 C 84 le quartz est de 4 
; Mhz , on effectue une tempo environ �gale � 0.2 seconde. 
; un bouton marche sur le port A permet de lancer le clignotant � une 1 �re fr�quence. 
; un 2 �me bouton permet d' obtenir une 2 eme fr�quence
; un 3 �me bouton permet d' obtenir une 3 eme fr�quence

;------------   Directive d' assemblage pour MPLAB   ---------------

	list	p=16f84A
	#include p16f84A.inc

;------------   D�finition des constantes   ---------------

#define	inter0	0		; bouton marche
#define inter1	1		; bouton 1 ere fr�quence
#define inter2	2		; bouton 2 ere fr�quence
					
;------------   D�finition des registres temporaires   ---------------

retard1		EQU        0x0C      ;	 le registre temporaire retard1 se trouve � l' adresse 0C
tp2		EQU        0x10      ; 	le registre temporaire tp2 se trouve � l' adresse 10
retard2		EQU        0x0F      ;	 le registre temporaire retard1 se trouve � l' adresse 0F
memo		EQU        0x12      ;	 le registre temporaire memo se trouve � l' adresse 12
	
;------------   Init des ports A et B   ---------------

          ORG     0       		; on assemble � partir de l'adresse 0
	  
          BSF STATUS,5	; on met � 1 le 5eme bit du registre status pour acc�der
    				; � la 2eme page m�moire ( pour trisa et trisb )

          MOVLW 0x00  	; on met 00 dans le registre W
          MOVWF TRISB  	; on met 00 dans le port B il est programm� en sortie

          MOVLW 0x1F 	; on met 1F dans le registre W
          MOVWF TRISA   	; on met 1F dans le port A il est programm� en entr�e
	  
          BCF STATUS,5	; on remet � 0 le 5eme bit du registre status pour acc�der	
				; � la 1eme page m�moire 


;------------   raz de la led et du registre memo  ---------------


         MOVLW  0x00              ; on met 00 dans le registre W
         MOVWF  PORTB          ; on met W sur le port B ( led )
         MOVWF  memo            ; on met W dans le registre memo
         MOVWF tp2                 ; on met W dans le registre tp2

;------------   Programme principal   ---------------
debut
 	
	 btfss PORTA,inter0	; interrupteur 0 ( marche ) appuy� ? si oui on continu sinon 
	 goto debut 		; va � debut 

; -------------------- Test des inters ----------------------
         btfss PORTA,inter1	; interrupteur 1 ( freq 1 ) appuy� ? si non on va � suite
         goto suite
         MOVLW 0x01             ; on met 01 dans le registre W
         MOVWF tp2               ; on met W dans le registre tp2 

suite	 

         btfss PORTA,inter2     ; interrupteur 2 ( freq 2 ) appuy� ? si oui va � freq2 			
         goto suite2
         MOVLW 0x02             ; on met 02 dans le registre W
         MOVWF tp2               ; on met W dans le registre tp2 

suite2


         MOVLW 0xFF            ; on met ff dans le registre W
         MOVWF retard1         ; on met W dans le registre retard1 ( 1 ere fr�quence )
         MOVWF retard2         ; on met W dans le registre retard2 ( 1 ere fr�quence )
         
         MOVLW 0xAA            ; on met AA dans le registre W ( 2 eme fr�quence )
         btfsc tp2,0	            ; on test le bit 0 de tp2 si = 1 alors on saute la prochaine 					;instruction
         MOVWF retard2          ; sinon on met W dans le registre retard2 ( 2 ere fr�quence )

         MOVLW 0x55              ; on met 55 dans le registre W ( 3 eme fr�quence )
         btfsc tp2,1	            ; on test le bit 1 de tp2 si = 1 alors on saute la prochaine 					; instruction
         MOVWF retard2          ; sinon on met W dans le registre retard2 ( 3 ere fr�quence )

         COMF memo,F 		; On effectue le compl�ment du registre memo et 
         MOVF memo,W           ; on met le resultat dans W	
         MOVWF  PORTB        ; on met W sur le port B ( leds )
         CALL  tempo               ; on appel la temporisation
         GOTO  debut               ; retour au d�but du programme


;------------   Programme de temporisation    ---------------

tempo

          DECFSZ retard1,F       ; on d�cr�mente retard1 et on saute la prochaine instruction si 
          GOTO  tempo              ; le registre retard1 = 0 sinon retour � tempo

          movlw 0xFF		 ; on recharge retard1
          movwf retard1

          DECFSZ retard2,F       ; on d�cr�mente retard2 et on saute la prochaine instruction si 
          GOTO  tempo              ; le registre retard2 = 0 sinon retour � tempo


          movlw 0x00	  	 ; On met 0 dans TP2
          movwf tp2
	  
          RETURN                  ; retour au programme principal apr�s l 'instruction CALL

          END
 






