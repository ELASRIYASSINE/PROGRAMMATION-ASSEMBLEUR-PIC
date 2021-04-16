
;------------   Directive d' assemblage pour MPLAB   ---------------
	list	p=16f84A
	#include p16f84A.inc

;------------   Définition des constantes   ---------------
#define inter0 0	   ; bouton marche

;------------   Définition des registres temporaires   ---------------
retard1      EQU        0x0C      ; le registre temporaire retard1 se trouve à l' adresse 0C
retard2      EQU        0x0D      ; le registre temporaire retard2 se trouve à l' adresse 0D
memo       EQU        0x0E      ; le registre memo tampon se trouve à l' adresse 0E

;------------   Init des ports A et B   ---------------
	ORG 0
	bsf STATUS,5                       ; on met à 1 le 5eme bit du registre status pour accéder
                                                         ; à la 2eme page mémoire ( pour trisa et trisb )
	MOVLW B'00000000'     	; on met 00 dans le registre W
	MOVWF TRISB           	; on met 00 dans le port B il est programmé en sortie
	MOVLW 0x1F            	; on met 1F dans le registre W
	MOVWF TRISA           	; on met 00 dans le port A il est programmé en entrée
	bcf STATUS,5                      ; on remet à 0 le 5eme bit du registre status pour accéder
	                                          ; à la 1ere page mémoire

;------------   Programme principal   ---------------
Main

        btfss PORTA,inter0       ; interrupteur 0 ( marche ) appuyé ? si oui on continu sinon 
        goto Main		; on va à l' étiquette Main

         MOVLW  0xFF            ; on met 255 dans le registre W
         MOVWF  retard1         ; on charge retard1 avec 255 ( FFh contenu du registre W )
         MOVLW  0xFF            ; on met 255 dans le registre W
         MOVWF  retard2         ; on charge retard2 avec 255 ( FFh contenu du registre W )
         MOVF  memo, W         ; on met memo dans W
         MOVWF  PORTB         ; on met W sur le port B ( leds )
         CALL  tempo               ; on appel la temporisation
         MOVLW  0x01             ; on met 1 dans le registre W
         ADDWF  memo, F        ; on additionne memo + 1
         GOTO  Main                 ; retour au début du programme

;------------   Programme de temporisation ( 0.2 s )   ---------------

tempo
          DECFSZ retard1,F        ; on décrémente retard1 et on saute la prochaine instruction si 
          GOTO  tempo              ; le registre retard1 = 0 sinon retour à tempo
          MOVLW 0xFF             ; on met 255 dans le registre W
          MOVWF retard1          ; on charge retard1 avec 255 ( FFh contenu du registre W )
          DECFSZ retard2,F       ; on décrémente retard1 et on saute la prochaine instruction si 
          GOTO  tempo              ; le registre retard1 = 0 sinon retour à tempo
          RETURN                     ; retour au programme principal après l 'instruction CALL

          END                            ; fin du programme
