;------   Exemple d'application avec un PIC : Un d�codage de clavier -------

; Titre : D�codage d'un clavier
; Date : 01 JUILLET 2000
; Auteur : P.M
; PIC utilis� : PIC 16 F 84
; On r�alise un d�codage de clavier sur les broches RB0 � RB5 d' un PIC 16 F 84.
; Le port A est programm� en sortie les broches RA0 � RA3 renvoient le code binaire
; de la touche appuy�e.
; Les touches sont m�moris�es en E�PROM ainsi on peut configurer n' importe quel clavier.


;------------   Directive d' assemblage pour PLAB   ---------------

	list	p=16f84A
	#include p16f84A.inc
	__config H'3FF9'   
				
;------------   D�finition des registres temporaires   ---------------

retard1         EQU        0x0C      ; le registre temporaire retard1 se trouve � l' adresse 0C
retard2         EQU        0x0F      ; le registre temporaire retard2 se trouve � l' adresse 0F
colonne        EQU	      0x14     ; le registre colonne est � l'adresse 14
tampon	     EQU	      0x10	    ; le registre tampon est � l'adresse 10
rang	     EQU        0x11      ; le registre rang est � l'adresse 11
key	     EQU	      0x12     ; le registre key est � l'adresse 12

;------------   Mise en E�PROM du clavier utilis� ---------------

	org H'2100'    			; Donn�es EEPROM les 16 touches sont m�moris�es 
					; selon le type de clavier

	DE  0x01,0x02,0x03,0x0A		; 1 ere rang�e ( 1,2,3,A )
	DE  0x04,0x05,0x06,0x0B		; 2 eme rang�e ( 4,5,6,B )
	DE  0x07,0x08,0x09,0x0C		; 3 eme rang�e ( 7,8,9,C )
	DE  0x0E,0x00,0x0F,0x0D		; 4 eme rang�e ( E,0,F,D )

;------------   Init des ports A et B   ---------------

	ORG 0
	  
	bsf STATUS,5		; on met � 1 le 5eme bit du registre status pour acc�der
    				; � la 2eme page m�moire ( pour trisa et trisb )

	MOVLW B'11000011'     	; on met C3 dans le registre W
	MOVWF TRISB           	; on met C3 dans le port B il est programm� partiellement en E/S

	MOVLW 0x00            	; on met 00 dans le registre W
	MOVWF TRISA           	; on met 00 dans le port A il est programm� en sortie
	
	bcf STATUS,5		; on remet � 0 le 5eme bit du registre status pour acc�der	
				; � la 1eme page m�moire 

;------------   Init  ---------------

              MOVLW 0x00           	; on met 00 dans le registre W
              MOVWF PORTA          	; on met 00 sur le port A ( leds eteintes )

init

              MOVLW 0x00           	; on met 00 dans le registre W
	MOVWF tampon		; on met 00 dans le registre tampon
	MOVWF  PORTB                  ; on met W sur le port B 

	MOVLW  04       	              ; on met 4 dans le registre W 
	MOVWF  rang                      ; on met W rang ( 1 ere rang�e scrut�e )

;--------------------   Programme principal   ----------------------

debut
	 movf rang,w		; on met rang dans W
 	 MOVWF  PORTB                 ; on met W sur le port B ( N� rang= N� ligne aliment�e )
	 
	 MOVLW 0x00                       ; on met 00 dans le registre W
               MOVWF colonne                   ; on met 00 dans la variable colonne
	 BTFSC PORTB,6		 ; on teste le bit RB6 si = 0 on saute la prochaine instruction	
	 call sauve                           ; appel du sous programme si la touche est appuy�e

               MOVLW 0x01                      ; on met 01 dans le registre W
               MOVWF colonne                  ; on met 01 dans la variable colonne
	 BTFSC PORTB,7		; on teste le bit RB7 si = 0 on saute la prochaine instruction	
	 call sauve
	 
               MOVLW 0x02                     ; on met 02 dans le registre W
               MOVWF colonne                 ; on met 02 dans la variable colonne
	 BTFSC PORTB,1		; on teste le bit RB1 si = 0 on saute la prochaine instruction	
	 call sauve
	 
               MOVLW 0x03                     ; on met 03 dans le registre W
               MOVWF colonne                 ; on met 03 dans la variable colonne
	 BTFSC PORTB,0		; on teste le bit RB0 si = 0 on saute la prochaine instruction	
	 call sauve

 
	 movf rang,W		; on met rang dans W
	 SUBLW 0x20	              ; W - 32 -> W 
	 BTFSC STATUS,2		; on teste le bit Z si Z=0 on saute la prochaine instruction	
	 GOTO init

	 movf rang,W		; on met rang dans W
               ADDWF  rang, F		; on additionne rang + rang

               MOVLW  0x04                     ; on met 4 dans le registre W
               ADDWF  tampon, F              ; on additionne tampon + 4
 
	 GOTO debut

;------------   D�termination de la touche appuy�e   ---------------

sauve
	 movf PORTB,W		; on met le port B (clavier) dans W 
	 MOVWF key		; on sauve W dans key

	
	 MOVF  tampon, W                ; on met tampon dans W
	 addwf colonne,W	               ; tampon + colonne --> W

               MOVWF  EEADR                 ; on met W sur EEADR ( adresse E�PROM )
	 bsf STATUS,5	              ; on met � 1 le 5eme bit du registre status pour acc�der
    			              ; � la 2eme page m�moire ( EECON1 )

               MOVLW 0x01                      ; on met 01 dans le registre W
               MOVWF EECON1                 ; on met 01 dans le registre EECON1
 	 bcf STATUS,5		; on remet � 0 le 5eme bit du registre status 
				
                 
               MOVF  EEDATA, W              ; on met la donn�e E�PROM dans W
  	 MOVWF PORTA                   ; on met W sur le port A                   

	 CALL tempo                         ; appel du sous programme de temporisation

;---------------- test de l'appui maintenu ---------------------

appui
	 BTFSC PORTB,6		; on teste le bit RB6 si = 1 on va � appui	
	 GOTO appui
	 BTFSC PORTB,7		; on teste le bit RB7 si = 1 on va � appui	
	 GOTO appui
	 BTFSC PORTB,1		; on teste le bit RB1 si = 1 on va � appui	
	 GOTO appui
	 BTFSC PORTB,0		; on teste le bit RB0 si = 1 on va � appui	
	 GOTO appui


	 return


;------------   Programme de temporisation   ---------------

tempo
	MOVLW 0xff               ; on met ff dans le registre W
	MOVWF retard1          ; on met W dans le registre retard1 
	MOVWF retard2          ; on met W dans le registre retard2 

attente

	DECFSZ retard1,F       ; on d�cr�mente retard1 et on saute la prochaine instruction si 
	GOTO  attente            ; le registre retard1 = 0 sinon retour � tempo

	movlw 0xFF	     ; on recharge retard1
	movwf retard1

	DECFSZ retard2,F       ; on d�cr�mente retard2 et on saute la prochaine instruction si 
	GOTO  attente            ; le registre retard2 = 0 sinon retour � tempo
	  
	RETURN                    ; retour au programme principal apr�s l 'instruction CALL


	END
 






