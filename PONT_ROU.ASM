;------------   Exemple d'application avec un PIC : Le pont roulant   ---------------

; Titre : Pont roulant
; Date : 01 juillet 2000
; Auteur : P.MAYEUX
; PIC utilis� : PIC 16 F 84
; On r�alise la simulation d' un pont roulant en utilisant les broches RA0 � RA4 
; pour le bouton marche, le coup de poing d' arr�t d'urgence les deux fin de
; course gauche et droit et le bouton poussoir 'descente'.
; Les broches RB0 � RB4 repr�sentent la pr�sence tension, le d�placement � gauche,
; le d�placement � droite, la mont�e et la descente.
; Les broches RB5 � RB7 font l' acquisition des boutons poussoirs 'gauche,droite et mont�e'
; on consid�re dans cette application que les but�es hautes et basses sont ins�r�es 
; dans la puissance et arr�tent le mouvement ( le PIC utilis� ne comporte que 13 E/S )
  
; Entr�es : RA0= Marche       		RA1= Arr�t                 RA2= But�e gauche       RA3= but�e droite
; Entr�es : RA4= BP descente  		RB5= BP gauche        RB6= BP droite              RB7= BP mont�e
; Sorties : RB0= Voy Pr�sence tension                RB1= Voy Gauche      RB2= Voy Droite            RB3= Voy Mont�e
; Sorties : RB4= Voy Descente


;------------   Directive d' assemblage pour PLAB   ---------------

	list	p=16f84A
	#include p16f84A.inc
	__config H'3FF9'   

 
;------------   D�finition des constantes   ---------------

#define 			              bp_marche 0   	 ; bouton marche
#define				arret 1	   	 ; bouton arr�t
#define				butee_g 2	 ; butee gauche
#define				butee_d 3	 ; butee droite
#define				bp_desc 4	; bouton poussoir descente
#define				bp_g 5		; bouton poussoir gauche
#define				bp_d 6		; bouton poussoir droite
#define				bp_m 7		; bouton poussoir montee
#define				PT 0		; voyant pr�sence tension
#define				voy_g 1		; voyant d�placement � gauche
#define				voy_d 2		; voyant d�placement � droite
#define				voy_m 3		; voyant d�placement vers le haut
#define				voy_desc 4	; voyant d�placement vers le bas

					
;------------   Mise en E�PROM de la version du programme   ---------------

	org H'2100'    			; Donn�es EEPROM 
	DE  "Pont Roulant, v1.0", 0		; indique la version du logiciel

;------------   Init des ports A et B  ---------------


	ORG 0
	  
	bsf STATUS,5		; on met � 1 le 5eme bit du registre status pour acc�der
    				; � la 2eme page m�moire ( pour trisa et trisb )

	MOVLW  B'11100000'           ; on met E1 dans le registre W 
	MOVWF TRISB           	; Le Port B est programm� en sortie de RB0 � RB4

	MOVLW  0x1F	              ; on met 1F dans le registre W 
	MOVWF TRISA           	; Le port A  est programm� en entr�e 
	
	bcf STATUS,5		; on remet � 0 le 5eme bit du registre status pour acc�der	
				; � la 1eme page m�moire 
;--------------------   Programme principal   ----------------------


init
	MOVLW  B'00000000'           ; on met 00 dans le registre W ( arret )
	MOVWF  PORTB                  ; on met W sur le port B ( led )

debut

	btfsc PORTA,arret	              ; interrupteur  arret  appuy� ? si oui on  
	goto init   	              ; va � init
	
	btfsc PORTA,bp_marche	; interrupteur  marche  appuy� ? si oui on  
	call marche     	              ; va � marche

	btfss PORTA,bp_marche	; interrupteur  marche  appuy� ? si non on  
	goto init 	     	              ; va � init
	
	btfsc PORTB,bp_m       	; BP mont�e appuy� ? si oui on 
	goto montee   		; va � montee
	BCF PORTB,voy_m   	; raz voyant mont�e 

	btfsc PORTA,bp_desc	; BP descente appuy� ? si oui on 
	goto descente  		; va � descente
	BCF PORTB,voy_m   	; raz voyant mont�e 

	btfsc PORTB,bp_d	              ; BP droite appuy� ? si oui on 
	goto droite   		; va � droite
	BCF PORTB,voy_d   	; raz voyant droite

	btfsc PORTB,bp_g	              ; BP gauche appuy� ? si oui on 
	goto gauche  		; va � gauche
	BCF PORTB,voy_g   	; raz voyant gauche 

	goto debut

marche
	BSF PORTB,PT                    ; on allume le voyant 'Pr�sence tension'
	return

montee
              BSF PORTB,voy_m	              ; on allume le voyant 'mont�e'
	goto debut

descente
              BSF PORTB,voy_desc          ; on allume le voyant 'descente'
	goto debut

droite       
              BSF PORTB,voy_d	              ; on allume le voyant 'droite'
	btfsc PORTA,butee_d	; But�e droite actionn�e ? si oui on 
	BCF PORTB,voy_d		; raz le voyant 'droite'
	goto debut

gauche
              BSF PORTB,voy_g	              ; on allume le voyant 'gauche'
	btfsc PORTA,butee_g	; But�e droite actionn�e ? si oui on 
	BCF PORTB,voy_g		; raz le voyant 'gauche'
	goto debut


	END
 






