;------------   Exemple d'application avec un PIC : Un cycle pneumatique   ---------------

; Titre : Simulation pneumatique
; Date : 01 juillet 2000
; Auteur : P.MAYEUX
; PIC utilisé : PIC 16 F 84
; On réalise la simulation d' un montage pneumatique en utilisant les broches RA0 à RA3 
; pour le bouton marche, le coup de poing d' arrêt d'urgence et les deux fin de
; course du vérin N°1.
; Les broches RB0 à RB4 représentent les électrovalves EV1,EV2,EV3,EV4,EV5
; Les broches RB5 à RB7 font l' acquisition fin de course des vérins N°2 et 3

; Entrées : RA0= Marche       		RA1= Arrêt              RA2= FC1                  RA3= FC2
; Entrées : RB5= FC3                                        RB6= FC4	  RB7= FC5
; Sorties : RB0= EV1			RB1= EV2	  RB2= EV3	      RB3= EV4
; Sorties : RB4= EV5


;------------   Directive d' assemblage pour PLAB   ---------------

	list	p=16f84A
	#include p16f84A.inc
	__config H'3FF9'   

 
;------------   Définition des constantes   ---------------

#define 			              bp_marche 0   	 ; bouton marche
#define				arret 1	   	 ; bouton arrêt
#define				FC1   2		 ; fin de course rentrée vérin N° 1
#define				FC2   3		 ; fin de course sortie vérin N° 1
#define				FC3   5		 ; fin de course rentrée vérin N° 2
#define				FC4   6		 ; fin de course rentrée vérin N° 3
#define				FC5   7		 ; fin de course sortie vérin N° 3
#define				EV1   0		 ; Electro-valve vérin N°1 rentrée
#define				EV2   1		 ; Electro-valve vérin N°1 sortie
#define				EV3   2		 ; Electro-valve vérin N°2 rentrée
#define				EV4   3		 ; Electro-valve vérin N°3 rentrée
#define				EV5   4		 ; Electro-valve vérin N°3 sortie


retard1      EQU        0x0C      ; le registre temporaire retard1 se trouve à l' adresse 0C
retard2      EQU        0x0F      ; le registre temporaire retard2 se trouve à l' adresse 0F
retard3      EQU        0x10      ; le registre temporaire retard3 se trouve à l' adresse 10

OPTION_REG   EQU        H'0081'	  
					
;------------   Mise en E²PROM de la version du programme   ---------------

	org H'2100'    			              ; Données EEPROM 
	DE  "Simulation pneumatique, v1.0", 0		; indique la version du logiciel

;------------   Init des ports A et B  ---------------


	ORG 0
	  
	bsf STATUS,5		; on met à 1 le 5eme bit du registre status pour accéder
    				; à la 2eme page mémoire ( pour trisa et trisb )

	MOVLW  B'11100000'            ; on met E1 dans le registre W 
	MOVWF TRISB           	; Le Port B est programmé en sortie de RB0 à RB4

	MOVLW  0x1F	              ; on met 1F dans le registre W 
	MOVWF TRISA           	; Le port A  est programmé en entrée 

	
	bcf STATUS,5		; on remet à 0 le 5eme bit du registre status pour accéder	
				; à la 1eme page mémoire 

;--------------------   Programme principal   ----------------------


init
	MOVLW  B'00000000'           ; on met 00 dans le registre W ( arret )
	MOVWF  PORTB                  ; on met W sur le port B ( led )

debut

	btfsc PORTA,arret	              ; interrupteur  arret  appuyé ? si oui on  
	goto init   		; va à init
	
	btfss PORTA,bp_marche	; interrupteur  marche  appuyé ? si oui on  
	goto debut		; continu

	BSF PORTB,EV1                  ; Sortie vérin N°1 impulsion EV1
	call tempo		; appel de la temporisation
	BCF PORTB,EV1                  ; impulsion EV1 = 0
fin2
	btfss PORTA,FC2		; FC2  appuyé ? si  non  
	goto fin2   		; va à fin2

	BSF PORTB,EV2                  ; Rentrée vérin N°1 impulsion EV2
	call tempo		; appel de la temporisation
	BCF PORTB,EV2                  ; impulsion EV2 = 0

fin1
	btfss PORTA,FC1		; FC1  appuyé ? si  non  
	goto fin1   		; va à fin1


	BSF PORTB,EV4                  ; Sortie vérin N°3 impulsion EV4
	call tempo		; appel de la temporisation
	BCF PORTB,EV4                  ; impulsion EV4 = 0
fin5
	btfss PORTB,FC5		; FC5  appuyé ? si  non  
	goto fin5   		; va à fin5

	BSF PORTB,EV5                  ; Rentrée vérin N°3 impulsion EV5
	call tempo		; appel de la temporisation
	BCF PORTB,EV5                  ; impulsion EV5 = 0
fin4
	btfss PORTB,FC4		; FC4  appuyé ? si  non  
	goto fin4   		; va à fin4


	BSF PORTB,EV3                  ; Rentrée vérin N°2 impulsion EV3
	call tempo		; appel de la temporisation
	BCF PORTB,EV3                  ; impulsion EV3 = 0

fin3
	btfss PORTB,FC3		; FC3  appuyé ? si  non  
	goto fin3  		; va à fin3


	goto debut


 
;------------   Programme de temporisation longue   ---------------

tempo
	MOVLW 0xff              ; on met ff dans le registre W
	MOVWF retard1         ; on met W dans le registre retard1 
	MOVWF retard2         ; on met W dans le registre retard2 
	MOVLW 0x07            ; on met 12 dans le registre W
	MOVWF retard3         ; on met W dans le registre retard3 

attente

	DECFSZ retard1,F       ; on décrémente retard1 et on saute la prochaine instruction si 
	GOTO  attente            ; le registre retard1 = 0 sinon retour à tempo

	movlw 0xff	     ; on recharge retard1
	movwf retard1

	DECFSZ retard2,F       ; on décrémente retard2 et on saute la prochaine instruction si 
	GOTO  attente            ; le registre retard2 = 0 sinon retour à tempo

	movlw 0xff	     ; on recharge retard2
	movwf retard2

	DECFSZ retard3,F       ; on décrémente retard3 et on saute la prochaine instruction si 
	GOTO  attente            ; le registre retard3 = 0 sinon retour à tempo
	  
	RETURN                    ; retour au programme principal après l 'instruction CALL


	END
 






