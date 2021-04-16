;-----   Application avec un PIC : Une platine autonome programmable ------

; Titre : platine autonome
; Date : 18 Aout 2001
; Auteur : P.M
; PIC utilisé : PIC 16 F 84
; Ce montage d'initiation à base de PIC 16C84 permet de réaliser une platine autonome
; programmable. La sortie à relais fonctionne selon 4 modes : 
; - Minuterie , - Retardateur , - Télérupteur , - Cadenceur
; ces quatre modes sont définis par switch.

; +++++++++++++ Options du logiciel : ++++++++++++++++++

; Les temporisations sont au nombre de quatre 5s , 30s , 1mn , 30mn
; ces quatre temporisations sont définies par switch.

;------------   Directive d' assemblage pour PLAB   ---------------

	list	p=16f84A
	#include p16f84A.inc
	__config H'3FF9'   

;------------   Définition des constantes   ---------------

W      			     EQU     0x00        ; variable W = 0 
F	 		     EQU     0x01        ; variable F = 1
					
;------------   Définition des registres temporaires   ---------------

retard1      EQU        0x0C      ; le registre temporaire retard1 pour la temporisation
retard2      EQU        0x0D      ; le registre temporaire retard2 pour la temporisation
retard3      EQU        0x19      ; le registre temporaire retard3 pour la temporisation 
retard4      EQU        0x12      ; le registre temporaire retard3 pour la temporisation 
mode_0	     EQU	0x14	  ; variable contenant le mode de fonctionnement à mémoriser en E²PROM
mode	     EQU	0x15	  ; variable contenant le mode de fonctionnement à réaliser
mode_1	     EQU	0x17	  ; variable contenant le mode de fonctionnement à mémoriser en E²PROM
adresse	     EQU	0x16	  ; variable contenant l 'adresse courante de l' E²PROM
mode_t	     EQU	0x20	  ; registre contenant la durée de temporisation à utiliser
temp	     EQU	0x21	  ; registre temporaire à utilisé pour la temporisation 
temp2	     EQU	0x22	  ; registre temporaire à utilisé pour la temporisation

;***********************   Numero de version  ********************************

	org h'2100'
	de "        "

	org h'2110'
	de "Platine autonome programmable ver 1.0 18/08/01 "

;***************************   Programme principal  **************************

	ORG 0
	
;******************************** INIT  **************************************

	bsf STATUS,5		; on met à 1 le 5eme bit du registre status pour accéder
    				; à la 2eme page mémoire ( pour trisa et trisb )
	MOVLW B'11111000'     	; rb3,rb4,rb5,rb6,rb7 en entrée
	MOVWF TRISB           	; on met 00 dans le port B il est programmé en sortie

	MOVLW B'11100001'       ; on met E1 dans le registre W
	MOVWF TRISA           	; ra1,ra2,ra3,ra4 en sortie ra0 en entrée
	
	bcf STATUS,5		; on remet à 0 le 5eme bit du registre status pour accéder	
				; à la 1eme page mémoire 
	clrf mode
	clrf adresse		
	clrf PORTA
	clrf PORTB
	
;******************* Test des entrées et du mode programmation *****************

debut
        MOVLW  0x01      	; on met 1 dans W
	movwf retard3
	movwf retard4

	call tempo

	BTFSc PORTB,3		; on teste le bit RB3 ( mode programmation ) si = 1 on va  
	goto prog		; à l' etiquette prog
		 
        BTFSs PORTA,0		; on teste le bit RA0 ( entrée N°0 ) si = 0 on va  
	goto entree		; à l' etiquette entree

	goto debut

;**************************** Mode autonome ************************************

entree

	call lecture		; choix du mode de fonctionnement (lecture E²PROM )
				; mode=choix fonctionnement,mode_t=choix durée de temporisation


;---- sélection de la durée de temporisation ----

        MOVLW  0x01      	; on met 1 dans W
	movwf temp
	movwf temp2

	movf mode_t,W		; on met le registre mode_t dans W
	sublw 0x00		; W - 0 --> W		
	btfsc STATUS,2		; on test le bit Z si Z= 0 on saute la prochaine instruction
	goto tempo_1		; temporisation de 5s

	movf mode_t,W		; on met le registre mode_t dans W
	sublw 0x01		; W - 1 --> W		
	btfsc STATUS,2		; on test le bit Z si Z= 0 on saute la prochaine instruction
	goto tempo_2		; temporisation de 30s

	movf mode_t,W		; on met le registre mode_t dans W
	sublw 0x02		; W - 2 --> W		
	btfsc STATUS,2		; on test le bit Z si Z= 0 on saute la prochaine instruction
	goto tempo_3		; temporisation de 1mn

	movf mode_t,W		; on met le registre mode_t dans W
	sublw 0x03		; W - 3 --> W		
	btfsc STATUS,2		; on test le bit Z si Z= 0 on saute la prochaine instruction
	goto tempo_4		; temporisation de 30mn

tempo_1
	MOVLW  0x19      	; on met 19 dans W (tempo de 5s)
	movwf temp		; 0.19s = 1 point sur temp

	goto choix
tempo_2
	MOVLW  0x9a      	; on met 9a dans W (tempo de 30s)
	movwf temp
	goto choix
tempo_3
	MOVLW  0x86      	; on met 86 dans W (tempo de 1mn)
	movwf temp
	MOVLW  0x2      	; on met 10 dans W (tempo de 30 mn)
	movwf temp2
	goto choix

tempo_4
	MOVLW  0xff      	; on met ff dans W (tempo de 30 mn)
	movwf temp
	MOVLW  0x37      	; on met 25 dans W (tempo de 30 mn)
	movwf temp2

;---- sélection du mode de fonctionnement ----

choix
	movf mode,W		; on met le registre mode dans W
	sublw 0x00		; W - 0 --> W		
	btfsc STATUS,2		; on test le bit Z si Z= 1 alors on va à minuterie
	goto minuterie	

	movf mode,W		; on met le registre mode dans W
	sublw 0x01		; W - 1 --> W		
	btfsc STATUS,2		; on test le bit Z si Z= 1 alors on va à retard
	goto retard

	movf mode,W		; on met le registre mode dans W
	sublw 0x02		; W - 2 --> W		
	btfsc STATUS,2		; on test le bit Z si Z= 1 alors on va à telerupt
	goto telerupt

	movf mode,W		; on met le registre mode dans W
	sublw 0x03		; W - 3 --> W		
	btfsc STATUS,2		; on test le bit Z si Z= 1 alors on va à cadence
	goto cadence

;**************************** Mode Minuterie ********************************

minuterie
	call relais_on
	call tempo2
	call relais_off

bouclage
	BTFSs PORTA,0		; on teste le bit RA0 si = 1 on saute la prochaine instruction  
	goto bouclage		

	goto debut	

;**************************** Mode retardé ********************************

retard
	call tempo2
	call relais_on
boucle
	BTFSs PORTA,0		; on teste le bit RA0 si = 1 on saute la prochaine instruction  
	goto boucle		

	call relais_off
	goto debut				

;**************************** Mode telerupteur ********************************

telerupt

	BTFSc PORTB,2		; on test l 'état du relais si = 0 on saute la prochaine instruction
	goto eteint

	BTFSs PORTB,2		; on test l 'état du relais si = 1 on saute la prochaine instruction
	goto allume

eteint
	call relais_off
	goto boucle1

allume
	call relais_on
	goto boucle1

boucle1
	BTFSs PORTA,0		; on teste le bit RA0 si = 1 on saute la prochaine instruction  
	goto boucle1		; on boucle tant que l'inter est sur "on"  ( 0 logique )

	call tempo

	goto debut

;**************************** Mode cadenceur ********************************

cadence

	call relais_on

	BTFSc PORTA,0		; on teste le bit RA0 si = 0 on saute la prochaine instruction  
	goto fin_cad		

	call tempo2
	call relais_off
	call tempo2
	
	goto cadence

fin_cad
	call relais_off
	goto debut

;**************************** Mode programmation ********************************

prog

	bsf PORTA,2		; mise à 1 du bit ra2 ( led jaune mode programmation )
	clrf adresse
	clrf mode_0
	clrf mode_1

;---- choix du mode de fonctionnement -----       	

	MOVLW  0x01      	; on met 1 dans W
	BTFSc PORTB,4		; on teste le bit RB4 si = 0 on saute la prochaine instruction  
	movwf mode_0		; on met le registre mode_0 à 1 

       	MOVLW  0x02      	
	BTFSc PORTB,5		; on teste le bit RB5 si = 0 on saute la prochaine instruction  
	movwf mode_1		; on met le registre mode_1 à 2 

	movf mode_0,W		; on additionne mode_0 et mode_1 --> mode_1
	addwf mode_1,f		; si mode_1=0 (minuterie);=1 (retard);=2(télérupt);=3(cadenceur)
	
       	MOVLW  0x02      	; on met 2 dans W (E²PROM adresse 2 = mode adresse 3 = temporisation)
	movwf adresse		; on met le contenu de W dans le registre adresse
	
	call EEPROM
 
;---- choix de la temporisation -----       	

	call tempo
	call tempo

	clrf mode_0
	clrf mode_1

	MOVLW  0x01      	; on met 1 dans W
	BTFSc PORTB,6		; on teste le bit RB6 si = 0 on saute la prochaine instruction  
	movwf mode_0		; on met le registre mode_0 à 1 

       	MOVLW  0x02      	
	BTFSc PORTB,7		; on teste le bit RB7 si = 0 on saute la prochaine instruction  
	movwf mode_1		; on met le registre mode_1 à 2 

	movf mode_0,W		; on additionne mode_0 et mode_1 --> mode_1
	addwf mode_1,f		; si mode_1=0 (5s); =1 (30s); =2(1mn); =3(30mn)

       	MOVLW  0x03      	; on met 3 dans W (E²PROM adresse 2 = mode adresse 3 = temporisation)
	movwf adresse		; on met le contenu de W dans le registre adresse

	call EEPROM

	call tempo
	call tempo

	bcf PORTA,2		; mise à 0 du bit RA2 ( led jaune mode programmation )

attente1

        BTFSc PORTB,3		; on teste le bit RB3 ( entrée prog ) si = 0 on saute la prochaine instruction
	goto attente1		; on attend que l'inter d'entrée soit actionné 

	goto debut

;**************************** Mémorisation en E²PROM ***************************

EEPROM
 	  bsf STATUS,5		; on met à 1 le 5eme bit du registre status pour accéder
    				; à la 2eme page mémoire ( pour EECON1 et EECON2 )
          MOVLW 0x04            ; on met 04 dans le registre W
          MOVWF EECON1          ; on met 04 dans le registre EECON1
	  
	  bcf STATUS,5		; on remet à 0 le 5eme bit du registre status  

          movf adresse,W        ; on met le registre EEPROM dans W
	  MOVWF EEADR           ; on met W sur EEADR ( adresse E²PROM )
          movf mode_1,W		; on met le contenu du registre mode dans W
	  MOVWF  EEDATA         ; on met W sur EEDATA ( donnée E²PROM )

   	  bsf STATUS,5		; on met à 1 le 5eme bit du registre status pour accéder 
    				; à la 2eme page mémoire ( pour EECON1 et EECON2 )
	  
	  movlw 0x55		; passage obligatoire pour ecrire en E²PROM
	  movwf EECON2		;...
	  movlw 0xAA		;...
	  movwf EECON2		;...
	  bsf EECON1,1		;...

	  bcf STATUS,5		; on remet à 0 le 5eme bit du registre status 
	  	  
	  return



;*********** Lecture E²PROM et affectation du mode de fonctionnement *************

lecture 

         MOVLW  0x02           ; on met 2 dans W (E²PROM adresse 2 = mode adresse 3 = temporisation)
	 movwf adresse	       ; on met le contenu de W dans le registre adresse

	 MOVF  adresse, W      ; on met le registre EEPROM dans W
         MOVWF  EEADR          ; on met W sur EEADR ( adresse E²PROM )
	 bsf STATUS,5	       ; on met à 1 le 5eme bit du registre status pour accéder
    			       ; à la 2eme page mémoire ( EECON1 )
         MOVLW 0x01            ; on met 01 dans le registre W
         MOVWF EECON1          ; on met 01 dans le registre EECON1
 	 bcf STATUS,5	       ; on remet à 0 le 5eme bit du registre status 
		 
	 MOVF  EEDATA, W       ; on met la donnée E²PROM dans W
	 movwf mode
	 
	 MOVLW  0x03           ; on met 3 dans W (E²PROM adresse 2 = mode adresse 3 = temporisation)
	 movwf adresse	       ; on met le contenu de W dans le registre adresse

	 MOVF  adresse, W      ; on met le registre EEPROM dans W
         MOVWF  EEADR          ; on met W sur EEADR ( adresse E²PROM )
	 bsf STATUS,5	       ; on met à 1 le 5eme bit du registre status pour accéder
    			       ; à la 2eme page mémoire ( EECON1 )
         MOVLW 0x01            ; on met 01 dans le registre W
         MOVWF EECON1          ; on met 01 dans le registre EECON1
 	 bcf STATUS,5	       ; on remet à 0 le 5eme bit du registre status 
		 
	 MOVF  EEDATA, W       ; on met la donnée E²PROM dans W
	 movwf mode_t 
         return

;********************* Commande du relais ON ***********************************

relais_on

	bsf PORTB,2		; mise à 1 du bit rb2 ( commande du relais )
	bsf PORTA,3		; on allume la led verte
	return
	
;********************* Commande du relais OFF ***********************************

relais_off

	bcf PORTB,2		; mise à 0 du bit rb2 ( inhibition du relais )
	bcf PORTA,3		; on éteint la led verte
	return

;********************** Temporisation courte T1 ******************************

tempo
	MOVLW 0xff             ; on met ff dans le registre W
	MOVWF retard1            ; on met W dans le registre retard1 
	MOVWF retard2            ; on met W dans le registre retard2 

attente

	DECFSZ retard1,F         ; on décrémente retard1 et on saute la prochaine instruction si 
	GOTO  attente            ; le registre retard1 = 0 sinon retour à tempo

	movlw 0xff		 ; on recharge retard1 avec ff
	movwf retard1

	DECFSZ retard2,F         ; on décrémente retard2 et on saute la prochaine instruction si 
	GOTO  attente            ; le registre retard2 = 0 sinon retour à tempo
	 
	RETURN                   ; retour au programme principal après l 'instruction CALL

;********************** Temporisation longue T2  *******************************

tempo2
	MOVLW 0xff             ; on met ff dans le registre W
	MOVWF retard1            ; on met W dans le registre retard1 
	MOVWF retard2            ; on met W dans le registre retard2 
	
	movf temp,W		 ; on met le registre temp dans W
	MOVWF retard3            ; on met W dans le registre retard3 

	movf temp2,W		 ; on met le registre temp2 dans W
	MOVWF retard4            ; on met W dans le registre retard4 


attente2

	DECFSZ retard1,F         ; on décrémente retard1 et on saute la prochaine instruction si 
	GOTO  attente2           ; le registre retard1 = 0 sinon retour à attente2

	movlw 0xff		 ; on recharge retard1 avec ff
	movwf retard1

	DECFSZ retard2,F         ; on décrémente retard2 et on saute la prochaine instruction si 
	GOTO  attente2           ; le registre retard2 = 0 sinon retour à attente2

	movlw 0xff		 ; on recharge retard2 avec ff
	movwf retard2

	DECFSZ retard3,F         ; on décrémente retard3 et on saute la prochaine instruction si 
	GOTO  attente2           ; le registre retard3 = 0 sinon retour à attente2

	movlw 0xa5		 ; on recharge retard3 avec aa
	movwf retard3

	DECFSZ retard4,F         ; on décrémente retard3 et on saute la prochaine instruction si 
	GOTO  attente2           ; le registre retard3 = 0 sinon retour à attente2

	return

	END
 






