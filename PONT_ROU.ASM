;------------   Exemple d'application avec un PIC : Le pont roulant   ---------------

; Titre : Pont roulant
; Date : 01 juillet 2000
; Auteur : P.MAYEUX
; PIC utilisé : PIC 16 F 84
; On réalise la simulation d' un pont roulant en utilisant les broches RA0 à RA4 
; pour le bouton marche, le coup de poing d' arrêt d'urgence les deux fin de
; course gauche et droit et le bouton poussoir 'descente'.
; Les broches RB0 à RB4 représentent la présence tension, le déplacement à gauche,
; le déplacement à droite, la montée et la descente.
; Les broches RB5 à RB7 font l' acquisition des boutons poussoirs 'gauche,droite et montée'
; on considère dans cette application que les butées hautes et basses sont insérées 
; dans la puissance et arrêtent le mouvement ( le PIC utilisé ne comporte que 13 E/S )
  
; Entrées : RA0= Marche       		RA1= Arrêt                 RA2= Butée gauche       RA3= butée droite
; Entrées : RA4= BP descente  		RB5= BP gauche        RB6= BP droite              RB7= BP montée
; Sorties : RB0= Voy Présence tension                RB1= Voy Gauche      RB2= Voy Droite            RB3= Voy Montée
; Sorties : RB4= Voy Descente


;------------   Directive d' assemblage pour PLAB   ---------------

	list	p=16f84A
	#include p16f84A.inc
	__config H'3FF9'   

 
;------------   Définition des constantes   ---------------

#define 			              bp_marche 0   	 ; bouton marche
#define				arret 1	   	 ; bouton arrêt
#define				butee_g 2	 ; butee gauche
#define				butee_d 3	 ; butee droite
#define				bp_desc 4	; bouton poussoir descente
#define				bp_g 5		; bouton poussoir gauche
#define				bp_d 6		; bouton poussoir droite
#define				bp_m 7		; bouton poussoir montee
#define				PT 0		; voyant présence tension
#define				voy_g 1		; voyant déplacement à gauche
#define				voy_d 2		; voyant déplacement à droite
#define				voy_m 3		; voyant déplacement vers le haut
#define				voy_desc 4	; voyant déplacement vers le bas

					
;------------   Mise en E²PROM de la version du programme   ---------------

	org H'2100'    			; Données EEPROM 
	DE  "Pont Roulant, v1.0", 0		; indique la version du logiciel

;------------   Init des ports A et B  ---------------


	ORG 0
	  
	bsf STATUS,5		; on met à 1 le 5eme bit du registre status pour accéder
    				; à la 2eme page mémoire ( pour trisa et trisb )

	MOVLW  B'11100000'           ; on met E1 dans le registre W 
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
	goto init   	              ; va à init
	
	btfsc PORTA,bp_marche	; interrupteur  marche  appuyé ? si oui on  
	call marche     	              ; va à marche

	btfss PORTA,bp_marche	; interrupteur  marche  appuyé ? si non on  
	goto init 	     	              ; va à init
	
	btfsc PORTB,bp_m       	; BP montée appuyé ? si oui on 
	goto montee   		; va à montee
	BCF PORTB,voy_m   	; raz voyant montée 

	btfsc PORTA,bp_desc	; BP descente appuyé ? si oui on 
	goto descente  		; va à descente
	BCF PORTB,voy_m   	; raz voyant montée 

	btfsc PORTB,bp_d	              ; BP droite appuyé ? si oui on 
	goto droite   		; va à droite
	BCF PORTB,voy_d   	; raz voyant droite

	btfsc PORTB,bp_g	              ; BP gauche appuyé ? si oui on 
	goto gauche  		; va à gauche
	BCF PORTB,voy_g   	; raz voyant gauche 

	goto debut

marche
	BSF PORTB,PT                    ; on allume le voyant 'Présence tension'
	return

montee
              BSF PORTB,voy_m	              ; on allume le voyant 'montée'
	goto debut

descente
              BSF PORTB,voy_desc          ; on allume le voyant 'descente'
	goto debut

droite       
              BSF PORTB,voy_d	              ; on allume le voyant 'droite'
	btfsc PORTA,butee_d	; Butée droite actionnée ? si oui on 
	BCF PORTB,voy_d		; raz le voyant 'droite'
	goto debut

gauche
              BSF PORTB,voy_g	              ; on allume le voyant 'gauche'
	btfsc PORTA,butee_g	; Butée droite actionnée ? si oui on 
	BCF PORTB,voy_g		; raz le voyant 'gauche'
	goto debut


	END
 






