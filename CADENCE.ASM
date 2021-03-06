;------   Exemple d'application avec un PIC : Un cadenceur pour essuie - glace -------

; Titre : cadenceur
; Date : 01 juillet 2000
; Auteur : P.M
; PIC utilis� : PIC 16 F 84
; Ce montage d'initiation � base de PIC 16C84 permet de r�aliser un cadenceur pour essuie glace. 
; on m�morise en E�PROM les diff�rents appuis sur le levier de commande des essuie glace puis
; une fois les 64 octets m�moris�s, on relance la lecture de l' E�prom pour r�p�ter les appuis
; m�moris�s.
; la base de temps est environ �gale � la seconde, cela signifie que l'on m�morise pendant 
; environ 1 minute les appuis sur le levier de commande des essuie glace


;------------   Directive d' assemblage pour PLAB   ---------------

	list	p=16f84A
	#include p16f84A.inc
	__config H'3FF9'   

 
;------------   D�finition des constantes   ---------------

W      			     EQU     0x00        ; variable W = 0 
F	 		     EQU     0x01        ; variable F = 1
					
;------------   D�finition des registres temporaires   ---------------

retard1      EQU        0x0C      ; le registre temporaire retard1 pour la temporisation
retard2      EQU        0x0D      ; le registre temporaire retard2 pour la temporisation
retard3      EQU        0x0E      ; le registre temporaire retard2 pour la temporisation

adresse	     EQU	0x0F	  ; le registre adresse est � l'adresse 0F
memo	     EQU	0x14	  ; le registre memo est � l'adresse 14

;------------   Init des ports A et B   ---------------

	ORG 0
	  
	bsf STATUS,5		; on met � 1 le 5eme bit du registre status pour acc�der
    				; � la 2eme page m�moire ( pour trisa et trisb )

	MOVLW B'00001111'     	; on met 0F dans le registre W
	MOVWF TRISB           	; on met 0F dans le port B il est programm� partiellement en sortie

	MOVLW 0x00            	; on met 00 dans le registre W
	MOVWF TRISA           	; on met 00 dans le port A il est programm� en sortie
	
	bcf STATUS,5		; on remet � 0 le 5eme bit du registre status pour acc�der	
				; � la 1eme page m�moire 

;------------------------   Init et RAZ  ---------------------------------
raz
	clrf adresse	            ; on met 00 dans le registre adresse
	clrf  PORTB                       ; on met 00 sur le port B 
	clrf memo		            ; on met memo � 0

init
              MOVLW  0x01                     ; on met 1 dans le registre W
	MOVWF PORTA                  ; on commande la led rouge 
    

;--------------------   Programme principal   ----------------------

debut 

	 MOVF  adresse, W              ; on met adresse dans W
	 SUBLW 0x3E	              ; W - 3E -> W ( on est � la 64 eme case m�moire E�PROM ? )
	 BTFSC STATUS,2		; on teste le bit Z si Z=0 on saute la prochaine instruction	
	 goto raz		              ; on remet � 0 le registre adresse
 
	 BTFSc PORTB,0		; on teste le bit RbO ( enreg ) si = 0 on saute la prochaine 	
	 goto memorise		; instruction sinon on va au sous programme memorise

	 BTFSc PORTB,1		; on teste le bit Rb1 ( replay ) si = 0 on saute la prochaine 	
	 goto replay		; instruction sinon on va au sous programme replay

	 GOTO raz

;---------------------- �criture E�PROM ---------------------------

memorise
	  bcf PORTB,7		; raz du 7eme bit du port B ( mode debug )
	  clrw		              ; raz de W
	  clrf memo		; raz du registre memo
	  BTFSc PORTB,2	              ; on teste le bit Rb2 ( entr�e levier de cde ) si = 0 on saute la prochaine 	
                MOVLW  0x01                    ; on met 1 dans le registre W
	  movwf memo                      ; on sauvegarde W dans le registre memo

	  BTFSc PORTB,2	              ; on teste le bit Rb2 ( entr�e levier de cde ) si = 0 on saute la prochaine 	
                bsf  PORTB,7                     ; on met 1 dans 7 eme bit du port b 

 	  bsf STATUS,5		; on met � 1 le 5eme bit du registre status pour acc�der
    				; � la 2eme page m�moire ( pour EECON1 et EECON2 )

                MOVLW 0x04                     ; on met 04 dans le registre W
                MOVWF EECON1               ; on met 04 dans le registre EECON1

	  bcf STATUS,5		; on remet � 0 le 5eme bit du registre status  

                movf adresse,W	              ; on met le registre adresse dans W
	  MOVWF EEADR                 ; on met W sur EEADR ( adresse E�PROM )
                movf memo,W		; on met le contenu du registre memo dans W
	  MOVWF  EEDATA              ; on met W sur EEDATA ( donn�e E�PROM )

   	  bsf STATUS,5		; on met � 1 le 5eme bit du registre status pour acc�der 
    				; � la 2eme page m�moire ( pour EECON1 et EECON2 )
	  
	  movlw 0x55		; passage obligatoire pour ecrire en E�PROM
	  movwf EECON2		;...
	  movlw 0xAA		;...
	  movwf EECON2		;...
	  bsf EECON1,1		;...

	  bcf STATUS,5		; on remet � 0 le 5eme bit du registre status 

	  call tempo
	  
	  MOVLW  0x01                   ; on met 1 dans le registre W
                ADDWF adresse, F            ; on additionne adresse + 1       

	  MOVF  adresse, W             ; on met adresse dans W
	  SUBLW 0x3E	              ; W - 3E -> W ( on est � la 64 eme case m�moire E�PROM ? )
	  BTFSC STATUS,2   	; on teste le bit Z si Z=0 on saute la prochaine instruction	
	  goto fin_enr		; on va au sous programme de fin d'enregistrement fin_enr
 	  
	  BTFSs PORTB,0		; on teste le bit RbO ( enreg ) si = 0 on saute la prochaine 	
	  goto debut		; instruction sinon on va au sous programme debut

	  goto memorise

fin_enr

	MOVLW B'00010000'     	; on met 10 dans le registre W
	MOVWF PORTB         	; on commande la led rouge ( fin d 'enregistrement )

              BTFSc PORTB,0		; on teste le bit RbO ( enreg ) si = 0 on saute la prochaine 	
	goto fin_enr		; instruction sinon on va au sous programme memorise

	goto raz

;---------------------- lecture E�PROM ---------------------------

replay

	 MOVF  adresse, W       ; on met adresse dans W
               MOVWF  EEADR          ; on met W sur EEADR ( adresse E�PROM )
	 bsf STATUS,5	       ; on met � 1 le 5eme bit du registre status pour acc�der
    			       ; � la 2eme page m�moire ( EECON1 )

               MOVLW 0x01               ; on met 01 dans le registre W
               MOVWF EECON1          ; on met 01 dans le registre EECON1
 	 bcf STATUS,5	        ; on remet � 0 le 5eme bit du registre status 
				
               MOVLW  0x01               ; on met 1 dans le registre W
               ADDWF adresse, F        ; on additionne adresse + 1       
               MOVF  EEDATA, W       ; on met la donn�e E�PROM dans W

	 SUBLW 01	       ; W - 01 -> W si w=1 alors on cde le relais pour les Essuie glace
	 BTFSC STATUS,2	       ; on teste le bit Z si Z=0 on saute la prochaine instruction	
	 call commande	       ; sinon on va au sous programme commande ( commande essuie glace )

	 call tempo

	 goto debut

;---------------   Commande essuie glace   --------------------

commande

	MOVLW B'00000110'     	; on met 06 dans le registre W
	MOVWF PORTA         	; on commande la led verte et le relais pendant 1 seconde
	call tempo_c
	MOVLW B'00000001'     	; on met 01 dans le registre W
	MOVWF PORTA         	; on commande la led rouge ( raz commande relais )
	return

;------------   Programme de temporisation longue  ---------------

tempo
	MOVLW 0xff                 ; on met ff dans le registre W
	MOVWF retard1            ; on met W dans le registre retard1 
	MOVWF retard2            ; on met W dans le registre retard2 
	MOVLW 0x60               ; on met 60 dans le registre W
	MOVWF retard3            ; on met W dans le registre retard3 

attente

	DECFSZ retard1,F         ; on d�cr�mente retard1 et on saute la prochaine instruction si 
	GOTO  attente              ; le registre retard1 = 0 sinon retour � tempo

	movlw 0xff	       ; on recharge retard1 avec ff
	movwf retard1

	DECFSZ retard2,F         ; on d�cr�mente retard2 et on saute la prochaine instruction si 
	GOTO  attente              ; le registre retard2 = 0 sinon retour � tempo

	movlw 0x10	       ; on recharge retard2
	movwf retard2

	DECFSZ retard3,F         ; on d�cr�mente retard3 et on saute la prochaine instruction si 
	GOTO  attente              ; le registre retard3 = 0 sinon retour � tempo
	  
	RETURN                      ; retour au programme principal apr�s l 'instruction CALL


;------------   Programme de temporisation courte  ---------------

tempo_c
	MOVLW 0xff                 ; on met ff dans le registre W
	MOVWF retard1            ; on met W dans le registre retard1 
	MOVWF retard2            ; on met W dans le registre retard2 

retour

	DECFSZ retard1,F         ; on d�cr�mente retard1 et on saute la prochaine instruction si 
	GOTO  retour                ; le registre retard1 = 0 sinon retour � tempo

	movlw 0xff	       ; on recharge retard1 avec ff
	movwf retard1

	DECFSZ retard2,F          ; on d�cr�mente retard2 et on saute la prochaine instruction si 
	GOTO  retour                 ; le registre retard2 = 0 sinon retour � tempo
	  
	RETURN                       ; retour au programme principal apr�s l 'instruction CALL

	END
 






