
;------------   Directive d' assemblage pour MPLAB   ---------------
	list	p=16f84A
	#include p16f84A.inc

;------------   D�finition des constantes   ---------------
#define inter0 0	   ; bouton marche

;------------   D�finition des registres temporaires   ---------------
retard1      EQU        0x0C      ; le registre temporaire retard1 se trouve � l' adresse 0C
retard2      EQU        0x0D      ; le registre temporaire retard2 se trouve � l' adresse 0D
memo       EQU        0x0E      ; le registre memo tampon se trouve � l' adresse 0E

;------------   Init des ports A et B   ---------------
	ORG 0
	bsf STATUS,5                       ; on met � 1 le 5eme bit du registre status pour acc�der
                                                         ; � la 2eme page m�moire ( pour trisa et trisb )
	MOVLW B'00000000'     	; on met 00 dans le registre W
	MOVWF TRISB           	; on met 00 dans le port B il est programm� en sortie
	MOVLW 0x1F            	; on met 1F dans le registre W
	MOVWF TRISA           	; on met 00 dans le port A il est programm� en entr�e
	bcf STATUS,5                      ; on remet � 0 le 5eme bit du registre status pour acc�der
	                                          ; � la 1ere page m�moire

;------------   Programme principal   ---------------
Main

        btfss PORTA,inter0       ; interrupteur 0 ( marche ) appuy� ? si oui on continu sinon 
        goto Main		; on va � l' �tiquette Main

         MOVLW  0xFF            ; on met 255 dans le registre W
         MOVWF  retard1         ; on charge retard1 avec 255 ( FFh contenu du registre W )
         MOVLW  0xFF            ; on met 255 dans le registre W
         MOVWF  retard2         ; on charge retard2 avec 255 ( FFh contenu du registre W )
         MOVF  memo, W         ; on met memo dans W
         MOVWF  PORTB         ; on met W sur le port B ( leds )
         CALL  tempo               ; on appel la temporisation
         MOVLW  0x01             ; on met 1 dans le registre W
         ADDWF  memo, F        ; on additionne memo + 1
         GOTO  Main                 ; retour au d�but du programme

;------------   Programme de temporisation ( 0.2 s )   ---------------

tempo
          DECFSZ retard1,F        ; on d�cr�mente retard1 et on saute la prochaine instruction si 
          GOTO  tempo              ; le registre retard1 = 0 sinon retour � tempo
          MOVLW 0xFF             ; on met 255 dans le registre W
          MOVWF retard1          ; on charge retard1 avec 255 ( FFh contenu du registre W )
          DECFSZ retard2,F       ; on d�cr�mente retard1 et on saute la prochaine instruction si 
          GOTO  tempo              ; le registre retard1 = 0 sinon retour � tempo
          RETURN                     ; retour au programme principal apr�s l 'instruction CALL

          END                            ; fin du programme
